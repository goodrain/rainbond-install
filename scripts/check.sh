#!/bin/bash

# Function : Check scripts for Rainbond install
# Args     : Null
# Author   : zhouyq (zhouyq@goodrain.com)
# Version  :
# 2018.03.22 first release

. scripts/common.sh

DEFAULT_LOCAL_IP="$(ip ad | grep 'inet ' | egrep ' 10.|172.|192.168' | awk '{print $2}' | cut -d '/' -f 1 | grep -v '172.30.42.1' | head -1)"


# Function : Check internet
# Args     : Check url
# Return   : (0|!0)
Check_Internet(){
  check_url=$1
  curl -s --connect-timeout 3 $check_url -o /dev/null 2>/dev/null
  if [ $? -eq 0 ];then
    return 0
  else
    err_log "Check if the network is normal"
  fi
}

# Name   : Get_Hostname and version
# Args   : hostname
# Return : 0|!0
Init_system(){
  hostname manage01
  echo "manage01" > /etc/hostname
  Write_Sls_File  hostname "$DEFAULT_HOSTNAME"

  version=$(cat ./VERSION)
  
  uuid=$(cat /proc/sys/kernel/random/uuid)
  Write_Sls_File host-uuid "$uuid"
  Write_Sls_File rbd-version "$version"
}


# Name   : Get_Rainbond_Install_Path
# Args   : config_path、config_path_again、install_path
# Return : 0|!0
Get_Rainbond_Install_Path(){

  if [ ! -z $RBD_PATH ];then
    if [[ "$RBD_PATH" =~ "rainbond" ]];then
      Echo_Info "[$RBD_PATH] is used to installation directory"
    else
      RBD_PATH=$RBD_PATH/rainbond
      Echo_Info "We need a sign for rainbond, what you input is changed to [$RBD_PATH]"
    fi
  else
    RBD_PATH=$DEFAULT_INSTALL_PATH 
  fi
  Write_Sls_File rbd-path $RBD_PATH
}

# Name   : Check_System_Version
# Args   : sys_name、sys_version
# Return : 0|!0
Check_System_Version(){
    sys_name=$(grep NAME /etc/os-release | head -1)
    sys_version=$(grep VERSION /etc/os-release |  head -1)
       [[ "$sys_version" =~ "7" ]] \
    || [[ "$sys_version" =~ "9" ]] \
    || [[ "$sys_version" =~ "16.04" ]] \
    || err_log "$sys_name$sys_version is not supported temporarily" \
    && return 0
}

# Name   : Get_Net_Info
# Args   : public_ips、public_ip、inet_ips、inet_ip、inet_size、
# Return : 0|!0
Get_Net_Info(){
  inet_ip=$(ip ad | grep 'inet ' | egrep ' 10.|172.|192.168' | awk '{print $2}' | cut -d '/' -f 1 | grep -v '172.30.42.1' | head -1)
  public_ip=$(ip ad | grep 'inet ' | grep -vE '( 10.|172.|192.168|127.)' | awk '{print $2}' | cut -d '/' -f 1 | head -1)
  Write_Sls_File inet-ip "${inet_ip}"
  if [ ! -z "$public_ip" ];then
    Write_Sls_File public-ip "${public_ip}"
  fi
  # 写入hosts
  echo "$inet_ip $(hostname)" >> /etc/hosts
}


# Name   : Get_Hardware_Info
# Args   : cpu_num、memory_size、disk
# Return : 0|!0
Get_Hardware_Info(){

    if [ $CPU_NUM -lt $CPU_LIMIT ] || [ $MEM_SIZE -lt $MEM_LIMIT ];then
      echo "We need $CPU_LIMIT CPUS,$MEM_LIMIT G Memories. You Have $CPU_NUM CPUS,$MEM_SIZE G Memories"
    fi
}

# Name   : Write_Config
# Args   : rbd_version、dns_value
# Return : 0|!0
Write_Config(){
  rbd_version=$(cat ./VERSION)
  dns_value=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}' | head -1)
  # Config rbd-version
  Write_Sls_File rbd-version "${rbd_version}"
  # Get current directory
  Write_Sls_File install-script-path "$PWD"
  # Config region info
  Write_Sls_File rbd-tag "cloudbang"
  # Get dns info
  Write_Sls_File dns "$dns_value"
}

# Name   : Install_Salt
# Args   : Null
# Return : 0|!0
Install_Salt(){
  # install salt without run
  ./scripts/bootstrap-salt.sh  -M -X -R $SALT_REPO  $SALT_VER 2>&1 > ${LOG_DIR}/${SALT_LOG} \
  || err_log "Can't download the salt installation package"

  inet_ip=$(grep inet-ip $PILLAR_DIR/system_info.sls | awk '{print $2}')
    # auto accept
cat > /etc/salt/master.d/master.conf <<END
interface: ${inet_ip}
open_mode: True
auto_accept: true
END


cat > /etc/salt/minion.d/minion.conf <<EOF
master: ${inet_ip}
id: $(hostname)
EOF

    ln -s $PWD/install/salt /srv/
    ln -s $PWD/install/pillar /srv/
    systemctl enable salt-master
    systemctl start salt-master
    systemctl enable salt-minion
    systemctl start salt-minion

    echo "wating 30s for check salt"
    sleep 30
    salt-key -L

}


# Name   : Write_Sls_File
# Args   : key
# Return : value
Write_Sls_File(){
  key=$1
  value=$2
  grep $key $PILLAR_DIR/system_info.sls > /dev/null
  if [ $? -eq 0 ];then
    sed -i -e "/$key/d" $PILLAR_DIR/system_info.sls
  fi
    echo "$key: $value" >> $PILLAR_DIR/system_info.sls
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
EOF
}

# -----------------------------------------------------------------------------
# init kubernetes configure
kubernetes(){
cat > ${PILLAR_DIR}/kubernetes.sls <<EOF
kubernetes:
  server:
    cfssl_image: rainbond/cfssl
    kubecfg_image: rainbond/kubecfg
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

err_log(){
  Echo_Error 
  Echo_Info "There seems to be some problem here, You can through the error log(./logs/error.log) to get the detail information"
  echo "$DATE $1" >> ./$LOG_DIR/error.log
  exit 1
}

check_rbd(){
  # Todo
  # Rbd_reg_notice 
  echo ""
}

#=============== main ==============

[ ! -f "/usr/lib/python2.7/site-packages/sitecustomize.py" ] && (
    cp ./scripts/sitecustomize.py /usr/lib/python2.7/site-packages/sitecustomize.py
    Echo_Info "Configure python defaultencoding"
    Echo_Ok
)

if [ -z "$1" ];then
  # disk cpu memory
  Echo_Info "Getting Hardware information ..."
  Get_Hardware_Info && Echo_Ok
fi

Echo_Info "Checking internet connect ..."
Check_Internet $RAINBOND_HOMEPAGE && Echo_Ok

Echo_Info "Setting [ manage01 ] for hostname"
Init_system && Echo_Ok

Echo_Info "Configing installation path ..."
Get_Rainbond_Install_Path  && Echo_Ok

Echo_Info "Checking system version ..."
Check_System_Version && Echo_Ok

#ipaddr(inet pub) type .mark in .sls
Echo_Info "Getting Network information ..."
Get_Net_Info && Echo_Ok

Echo_Info "Writing configuration ..."
Write_Config && Echo_Ok

Echo_Info "Installing salt ..."
Install_Salt && Echo_Ok

Echo_Info "Init config ..."
run && Echo_Ok

