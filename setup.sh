#!/bin/bash
#======================================================================================================================
#
#          FILE: setup.sh
#
#   DESCRIPTION: Install
#
#          BUGS: https://github.com/goodrain/rainbond-install/issues
#
#     COPYRIGHT: (c) 2018 by the Goodrain Delivery Team.
#
#       LICENSE: Apache 2.0
#       CREATED: 03/30/2018 10:49:37 AM
#======================================================================================================================

. scripts/common.sh

[ ! -d ./$LOG_DIR ] && mkdir ./$LOG_DIR
[ ! -d $PILLAR_DIR ] && mkdir $PILLAR_DIR || rm $PILLAR_DIR/* -rf
[ ! -f $PILLAR_DIR/system_info.sls ] && touch $PILLAR_DIR/system_info.sls

clear

# -----------------------------------------------------------------------------
# checking the availability of system

Echo_Banner "Rainbond Salt 1.0-rc"

check_func(){
    Echo_Info "will run check func."
    ./scripts/check_func.sh $@
}

install_func(){
    for ((i=1;i<=3;i++ )); do
        sleep 5
        echo "waiting salt start"
        salt-key -L | grep "manage" >/dev/null && export _EXIT=0 && break
    done
    Echo_Info "will install manage node."
    echo "start init"
    salt "*" state.sls init
    echo "start install storage"
    salt "*" state.sls storage
    echo "start install docker"
    salt "*" state.sls docker
    echo "start etcd"
    salt "*" state.sls etcd
    echo "start network plugin calico"
    salt "*" state.sls network
    echo "start k8s server"
    salt "*" state.sls kubernetes.server
    echo "start node"
    salt "*" state.sls node
    echo "start database mysql"
    salt "*" state.sls db
    echo "start plugins"
    salt "*" state.sls grbase
    salt "*" state.sls plugins
    echo "start proxy"
    salt "*" state.sls proxy
    echo "start prom"
    salt "*" state.sls prometheus
    
    Echo_Info "will install compute node."
    echo "start kubelet"
    salt "*" state.sls kubernetes.node
}

help_func(){
    echo "help:"
    echo "check   --- check cmd "
    echo "install --- install cmd "
    echo "dev     --- ignore check install cmd "
    echo ""
}

case $1 in
    check)
        check_func
    ;;
    install)
        check_func
        install_func
    ;;
    dev)
        check_func force
        install_func ${@:2}
    ;;
    *)
        help_func
    ;;
esac