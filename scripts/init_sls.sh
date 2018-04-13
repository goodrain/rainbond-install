#!/bin/bash

. scripts/common.sh

[[ $DEBUG ]] && set -x

# Name   : Get_Hostname and version
# Args   : hostname
# Return : 0|!0
Init_system(){
  hostname manage01
  echo "manage01" > /etc/hostname
  Write_Sls_File  hostname "$DEFAULT_HOSTNAME"

  LOCAL_IP=$(cat ./LOCAL_IP 2> /dev/null)
  DEFAULT_LOCAL_IP=${LOCAL_IP:-$DEFAULT_LOCAL_IP}
  
  Write_Sls_File rbd-version "$RBD_VERSION"
  Write_Sls_File inet-ip $DEFAULT_LOCAL_IP
  if [ ! -z "$DEFAULT_PUBLIC_IP" ];then
    Write_Sls_File public-ip "${DEFAULT_PUBLIC_IP}"
  fi

  # reset /etc/hosts
  echo -e "127.0.0.1\tlocalhost" > /etc/hosts

  # config hostname to hosts
  Write_Host "$DEFAULT_LOCAL_IP" "${DEFAULT_HOSTNAME}"

  return 0
}

# Name   : Get_Rainbond_Install_Path
# Args   : NULL
# Return : 0|!0
Get_Rainbond_Install_Path(){

  Echo_Info "[$DEFAULT_INSTALL_PATH] is used to installation rainbond."

  Write_Sls_File rbd-path $DEFAULT_INSTALL_PATH 
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

# -----------------------------------------------------------------------------
# init top configure
write_top(){
cat > ${PILLAR_DIR}/top.sls <<EOF
base:
  '*':
    - system_info
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
    write_top
}


# Name   : Install_Salt
# Args   : Null
# Return : 0|!0
Install_Salt(){
  # check salt service
  [ $(systemctl  is-active salt-master) == "active" ] && systemctl  stop salt-master
  [ $(systemctl  is-active salt-minion) == "active" ] && systemctl  stop salt-minion

  # install salt without run
  ./scripts/bootstrap-salt.sh  -M -X -R $SALT_REPO  $SALT_VER 2>&1 > ${LOG_DIR}/${SALT_LOG} \
  || Echo_Error "Failed to install salt!"

  Install_PKG "salt-ssh"

  inet_ip=$(grep inet-ip $PILLAR_DIR/system_info.sls | awk '{print $2}')
    # auto accept
cat > /etc/salt/master.d/master.conf <<END
interface: ${inet_ip}
open_mode: True
auto_accept: True
# 简介输出,当失败全部输出
state_output: mixed
# 当单个的状态执行失败后，将会通知所有的状态停止运行状态
failhard: True
END


cat > /etc/salt/minion.d/minion.conf <<EOF
master: ${inet_ip}
id: $(hostname)
# The level of log record messages to send to the console.
log_level: error
# The level of messages to send to the log file.
log_level_logfile: debug
EOF

echo "" > /etc/salt/roster

  [ -d /srv/salt ] && rm /srv/salt -rf
  [ -d /srv/pillar ] && rm /srv/pillar -rf
  cp -rp $PWD/install/salt /srv/
  cp -rp $PWD/install/pillar /srv/

  systemctl enable salt-master
  systemctl restart salt-master
  systemctl enable salt-minion
  systemctl restart salt-minion

  Echo_Info "Waiting to start salt."
  for ((i=1;i<=10;i++ )); do
    sleep 3
    echo -e -n "."
    uuid=$(salt "*" grains.get uuid | grep '-' | awk '{print $1}')
    [ ! -z $uuid ] && (
      Write_Sls_File reg-uuid "$uuid" /srv/pillar
      Write_Host "$DEFAULT_LOCAL_IP" "$uuid"
    ) && break
  done
  
  
  
}


Echo_Info "Init system config ..."
Init_system && Echo_Ok

Echo_Info "Configing installation path ..."
Get_Rainbond_Install_Path  && Echo_Ok

Echo_Info "Writing configuration ..."
Write_Config && Echo_Ok

Echo_Info "Init config ..."
run && Echo_Ok

Echo_Info "Installing salt ..."
Install_Salt && Echo_Ok

Echo_Info "REG Check info ..."
REG_Check && Echo_Ok