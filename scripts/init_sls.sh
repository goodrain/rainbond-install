#!/bin/bash

. scripts/common.sh

[[ $DEBUG ]] && set -x

# Name   : Get_Hostname and version
# Args   : hostname
# Return : 0|!0
Init_system(){

  MASTER_HOSTNAME=$(Read_Sls_File hostname)
  hostname $MASTER_HOSTNAME
  echo $MASTER_HOSTNAME > /etc/hostname

  LOCAL_IP=$(cat ./LOCAL_IP 2> /dev/null)
  DEFAULT_LOCAL_IP=${LOCAL_IP:-$DEFAULT_LOCAL_IP}
  
  Write_Sls_File master-ip $DEFAULT_LOCAL_IP
  
  Write_Sls_File public-ip "${DEFAULT_PUBLIC_IP}"

  # reset /etc/hosts
  echo -e "127.0.0.1\tlocalhost" > /etc/hosts

  # config hostname to hosts
  Write_Host "${DEFAULT_LOCAL_IP}" "${DEFAULT_HOSTNAME}"

  # Get current directory
  Write_Sls_File install-script-path "$PWD"

  # Get dns info
  Write_Sls_File dns "$dns_value"

}

# Name   : Install_Base_Pkg
# Args   : NULL
# Return : 0|!0
Install_Base_Pkg(){
  $Cache_PKG
  Install_PKG ${SYS_COMMON_PKGS[*]} ${SYS_BASE_PKGS[*]}

  #judgment below uses for offline env : do not exec ntp cmd ( changed by guox 2018.5.18 ).
  if [[ $1 != "offline" ]];then
    Echo_Info "update localtime"
    ntpdate ntp1.aliyun.com ntp2.aliyun.com ntp3.aliyun.com > /dev/null 2>&1 && Echo_Ok
  else
    return 0
  fi
}


# -----------------------------------------------------------------------------
# init database configure

db_init() {

## Generate random user & password
DB_USER=write
DB_PASS=$(echo $((RANDOM)) | base64 | md5sum | cut -b 1-8)

Write_Sls_File database.mysql.host ${DEFAULT_LOCAL_IP}
Write_Sls_File database.mysql.user ${DB_USER}
Write_Sls_File database.mysql.pass ${DB_PASS}

}

# -----------------------------------------------------------------------------
# init etcd configure

etcd(){

Write_Sls_File etcd.server.bind.host ${DEFAULT_LOCAL_IP}
Write_Sls_File etcd.server.token $(uuidgen)
Write_Sls_File etcd.server.members[0].host ${DEFAULT_LOCAL_IP}
Write_Sls_File etcd.server.members[0].name ${MASTER_HOSTNAME}

}


# -----------------------------------------------------------------------------
# init network-calico configure
calico(){

    IP_INFO=$(ip ad | grep 'inet ' | egrep ' 10.|172.|192.168' | awk '{print $2}' | cut -d '/' -f 1 | grep -v '172.30.42.1')
    IP_ITEMS=($IP_INFO)
    INET_IP=${IP_ITEMS%%.*}
    if [[ $INET_IP == '172' ]];then
        CALICO_NET=10.0.0.0/16
    elif [[ $INET_IP == '10' ]];then
        CALICO_NET=172.16.0.0/16
    else
        CALICO_NET=172.16.0.0/16
    fi

  Write_Sls_File network.calico.bind ${DEFAULT_LOCAL_IP}
  Write_Sls_File network.calico.net ${CALICO_NET}

}


# -----------------------------------------------------------------------------
# init top configure
write_top(){
cat > ${PILLAR_DIR}/top.sls <<EOF
base:
  '*':
    - custom
    - goodrain
    - etcd
    - network
    - kubernetes
    - db
    - plugins
EOF
}

run(){
    db_init
    etcd
    calico
    write_top
}


# Name   : Install_Salt
# Args   : Null
# Return : 0|!0
Install_Salt(){

  # check python env
  Echo_Info "Check python environment ..."
  Check_Python_Urllib && Echo_Ok
  
  # check salt service
  Echo_Info "Checking salt ..."
  Check_Service_State salt-master && systemctl stop salt-master
  Check_Service_State salt-minion && systemctl stop salt-minion

  # check and install salt 
  if [ ! $SALT_SSH_INSTALLED ];then
    # update repo mate
    Echo_Info "Installing salt ..."
    $Cache_PKG > /dev/null

    # install salt
    Install_PKG "$SALT_PKGS" 2>&1 > ${LOG_DIR}/${SALT_LOG} \
    || Echo_Error "Failed to install salt,see rainbond-install/${LOG_DIR}/${SALT_LOG} for more information."
  fi

  inet_ip=$(Read_Sls_File "master-ip" )

cat > /etc/salt/roster <<EOF
manage01:
  host: $inet_ip
  port: 22
  user: root
  priv: /etc/salt/pki/master/ssh/salt-ssh.rsa
EOF

[ -d "/root/.ssh" ] || (mkdir -p /root/.ssh && chmod 700 /root/.ssh )
[ -f "/etc/salt/pki/master/ssh/salt-ssh.rsa.pub" ] && cat /etc/salt/pki/master/ssh/salt-ssh.rsa.pub >> /root/.ssh/authorized_keys || (
  salt-ssh "*" w 2>&1 >/dev/null || cat /etc/salt/pki/master/ssh/salt-ssh.rsa.pub >> /root/.ssh/authorized_keys
)

  [ ! -d "~/.ssh/id_rsa" ] && (
    cp -a /etc/salt/pki/master/ssh/salt-ssh.rsa ~/.ssh/id_rsa
    cp -a /etc/salt/pki/master/ssh/salt-ssh.rsa.pub ~/.ssh/id_rsa.pub
  )

  [ -d /srv/salt ] && rm /srv/salt -rf
  [ -d /srv/pillar ] && rm /srv/pillar -rf
  cp -rp $PWD/install/salt /srv/
  cp -rp $PWD/install/pillar /srv/

  Echo_Info "Salt-ssh test."
  salt-ssh "*" --priv=/etc/salt/pki/master/ssh/salt-ssh.rsa  test.ping -i > /dev/null && Echo_Ok

  salt-ssh "*" state.sls salt.setup --state-output=mixed

  systemctl restart salt-master
  systemctl restart salt-minion

  Echo_Info "Waiting to start salt."
  for ((i=1;i<=10;i++ )); do
    echo -e -n "."
    sleep 1
    uuid=$(timeout 3 salt "*" grains.get uuid | grep '-' | awk '{print $1}')
    [ ! -z $uuid ] && (
      Write_Sls_File reg-uuid "$uuid"
      Write_Host "$DEFAULT_LOCAL_IP" "$uuid"
    ) && break
  done
}

Echo_Info "Install Base Package ..."
Install_Base_Pkg && Echo_Ok

Echo_Info "Init system config ..."
Init_system && Echo_Ok

Echo_Info "Init config ..."
run && Echo_Ok

# config salt
Install_Salt && Echo_Ok

Echo_Info "REG Check info ..."
REG_Check && Echo_Ok