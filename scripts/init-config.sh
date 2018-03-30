#!/bin/bash
#======================================================================================================================
#
#          FILE: init-config.sh
#
#   DESCRIPTION: Init configure for various systems/distributions
#
#          BUGS: https://github.com/goodrain/rainbond-install/issues
#
#     COPYRIGHT: (c) 2018 by the Goodrain Delivery Team.
#
#       LICENSE: Apache 2.0
#       CREATED: 03/30/2018 10:49:37 AM
#======================================================================================================================
set -o nounset                              # Treat unset variables as an error

# make sure we have a UID
[ -z "${UID}" ] && UID="$(id -u)"

# get the project's current path
PATH="$(pwd)"

# make sure we have DEFAULT_LOCAL_IP
[ -z "${DEFAULT_LOCAL_IP}" ] && DEFAULT_LOCAL_IP=$(ip ad | grep 'inet ' | egrep ' 10.|172.|192.168' | awk '{print $2}' | cut -d '/' -f 1 | grep -v '172.30.42.1' | head -1)

# check pillar dir
[ ! -d "$PATH/install/pillar" ] && mkdir -p "$PATH/install/pillar"

# -----------------------------------------------------------------------------
# checking the availability of commands

which_cmd() {
    which "${1}" 2>/dev/null || \
        command -v "${1}" 2>/dev/null
}

check_cmd() {
    which_cmd "${1}" >/dev/null 2>&1 && return 0
    return 1
}


# -----------------------------------------------------------------------------
# init database configure

db_init() {

## Generate random user & password
DB_USER=write
DB_PASS=$(echo $((RANDOM)) | base64 | md5sum | cut -b 1-8)

    cat > ${PATH}/install/pillar/db.sls <<EOF
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

cat > ${PATH}/install/pillar/etcd.sls <<EOF
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
cat > ${PATH}/install/pillar/kubernetes.sls <<EOF
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

if [ -z ${CALICO_NET} ];then
    IP_INFO=$(ip ad | grep 'inet ' | egrep ' 10.|172.|192.168' | awk '{print $2}' | cut -d '/' -f 1 | grep -v '172.30.42.1')
    IP_ITEMS=($IP_INFO)
    INET_IP=${IP_ITEMS%%.*}
    if [ $INET_IP = '172' ];then
        CALICO_NET=10.0.0.0/16
    elif [ $INET_IP = '10' ];then
        CALICO_NET=172.16.0.0/16
    else
        CALICO_NET=172.16.0.0/16
    fi
fi

cat > ${PATH}/install/pillar/network.sls <<EOF
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
cat > ${PATH}/install/pillar/plugins.sls <<EOF
plugins:
  core:
    api:
      image: rainbond/rbd-api
EOF
}

# -----------------------------------------------------------------------------
# init top configure
write_top(){
cat > ${PATH}/install/pillar/top.sls <<EOF
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

case $1 in
    *)
    run
    ;;
esac