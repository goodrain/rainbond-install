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
[[ $DEBUG ]] && set -x
. scripts/common.sh

[ ! -d ./$LOG_DIR ] && mkdir ./$LOG_DIR
[ ! -d $PILLAR_DIR ] && mkdir $PILLAR_DIR || rm $PILLAR_DIR/* -rf
[ ! -f $PILLAR_DIR/system_info.sls ] && touch $PILLAR_DIR/system_info.sls

 # trap program exit
trap 'Quit_Clear; exit' QUIT TERM EXIT

clear

# -----------------------------------------------------------------------------
# checking the availability of system

Echo_Banner "Rainbond v$RBD_VERSION"

check_func(){
    Echo_Info "Check func."
    ./scripts/check.sh $@
}

init_config(){
    Echo_Info "Init rainbond configure."
    ./scripts/init_sls.sh
}

install_func(){
    fail_num=0
    Echo_Info "will install manage node."

    for module in ${MANAGE_MODULES}
    do
        echo "Start install $module ..."
        if ! (salt "*" state.sls $module);then
            ((fail_num+=1))
            break
        fi
    done

    if [ "$fail_num" -eq 0 ];then
        REG_Status
        uuid=$(salt '*' grains.get uuid | grep "-" | awk '{print $1}')
        grctl node up $uuid
        Echo_Info "install successfully"
        grctl show
    fi
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
        check_func ${@:2} && init_config
    ;;
    install)
        check_func && init_config && install_func ${@:2}
    ;;
    dev)
        check_func force && init_config && install_func ${@:2}
    ;;
    *)
        help_func
    ;;
esac