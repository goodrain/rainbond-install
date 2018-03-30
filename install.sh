#!/bin/bash
#======================================================================================================================
#
#          FILE: install.sh
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

check_func(){
    echo "will run check func."
    ./scripts/check_func.sh
}

install_func(){
    echo "init config for salt."
    #./scripts/init-config.sh
    echo "will install manage node."
    #./scripts/install_manage.sh
    echo "will install compute node."
    #./scripts/install_compute.sh
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