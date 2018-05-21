#!/bin/bash

. scripts/common.sh

[[ $DEBUG ]] && set -x

# Name   : Get_Hostname and version
# Args   : hostname
# Return : 0|!0
Init_system(){
  hostname manage01
  echo "manage01" > /etc/hostname
  $YQBIN w $GLOBAL_SLS hostname "$DEFAULT_HOSTNAME"

  LOCAL_IP=$(cat ./LOCAL_IP 2> /dev/null)
  DEFAULT_LOCAL_IP=${LOCAL_IP:-$DEFAULT_LOCAL_IP}
  
  $YQBIN w $GLOBAL_SLS rbd-version "$RBD_VERSION"
  $YQBIN w $GLOBAL_SLS master-ip $DEFAULT_LOCAL_IP
  
  if [ ! -z "$DEFAULT_PUBLIC_IP" ];then
    $YQBIN w $GLOBAL_SLS public-ip "${DEFAULT_PUBLIC_IP}"
  else
    $YQBIN w $GLOBAL_SLS public-ip ""
  fi

  # reset /etc/hosts
  echo -e "127.0.0.1\tlocalhost" > /etc/hosts

  # config hostname to hosts
  Write_Host "${DEFAULT_LOCAL_IP}" "${DEFAULT_HOSTNAME}"

  return 0
}

# Name   : Get_Rainbond_Install_Path
# Args   : NULL
# Return : 0|!0
Get_Rainbond_Install_Path(){

  Echo_Info "[$DEFAULT_INSTALL_PATH] is used to installation rainbond."

  $YQBIN w $GLOBAL_SLS rbd-path "$DEFAULT_INSTALL_PATH"

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

# Name   : Write_Config
# Args   : null
# Return : 0|!0
Write_Config(){
  
  dns_value=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}' | head -1)
  # Config rbd-version
  Write_Sls_File rbd-version "${RBD_VERSION}"
  # Get current directory
  Write_Sls_File install-script-path "$PWD"
  # Config region info
  Write_Sls_File rbd-tag "rainbond"
  # Get dns info
  Write_Sls_File dns "$dns_value"
  # Get cli info
  Write_Sls_File cli-image "rainbond/static:allcli_v3.5"
}





# -----------------------------------------------------------------------------
# init database configure

db_init() {

## Generate random user & password
DB_USER=write
DB_PASS=$(echo $((RANDOM)) | base64 | md5sum | cut -b 1-8)

    cat > ${PILLAR_DIR}/db.sls <<EOF
database:
  mysql:
    image: rainbond/rbd-db:3.5
    host: ${DEFAULT_LOCAL_IP}
    port: 3306
    user: ${DB_USER}
    pass: ${DB_PASS}
EOF
}

# -----------------------------------------------------------------------------
# init etcd configure

etcd(){

cat > ${PILLAR_DIR}/etcd.sls <<EOF
etcd:
  server:
    image: rainbond/etcd:v3.2.13
    enabled: true
    bind:
      host: ${DEFAULT_LOCAL_IP}
    token: $(uuidgen)
    members:
    - host: ${DEFAULT_LOCAL_IP}
      name: manage01
      port: 2379
  proxy:
    image: rainbond/etcd:v3.2.13
    enabled: true
EOF
}

# -----------------------------------------------------------------------------
# init kubernetes configure
kubernetes(){
cat > ${PILLAR_DIR}/kubernetes.sls <<EOF
kubernetes:
  server:
    cfssl_image: rainbond/cfssl:dev
    kubecfg_image: rainbond/kubecfg:dev
    api_image: rainbond/kube-apiserver:v1.6.4
    manager: rainbond/kube-controller-manager:v1.6.4
    schedule: rainbond/kube-scheduler:v1.6.4
EOF
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


cat > ${PILLAR_DIR}/network.sls <<EOF
network:
  calico:
    image: rainbond/calico-node:v2.4.1
    enabled: true
    bind: ${DEFAULT_LOCAL_IP}
    net: ${CALICO_NET}
EOF
}

# -----------------------------------------------------------------------------
# init plugins configure
plugins(){
cat > ${PILLAR_DIR}/plugins.sls <<EOF
plugins:
  core:
    api:
      image: rainbond/rbd-api
EOF
}

custom_config(){
  # Todo
  echo ""
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
    kubernetes
    calico
    plugins
    custom_config
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

  inet_ip=$(Read_Sls_File "inet-ip" )

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

Echo_Info "Configing installation path ..."
Get_Rainbond_Install_Path  && Echo_Ok

Echo_Info "Writing configuration ..."
Write_Config && Echo_Ok

Echo_Info "Init config ..."
run && Echo_Ok

# config salt
Install_Salt && Echo_Ok

Echo_Info "REG Check info ..."
REG_Check && Echo_Ok