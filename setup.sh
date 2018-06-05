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

export MAIN_CONFIG="rainbond.yaml"

[ ! -f $MAIN_CONFIG ] && cp ${MAIN_CONFIG}.default ${MAIN_CONFIG}

. scripts/common.sh

 # trap program exit
trap 'Exit_Clear; exit' SIGINT SIGHUP
clear

# -----------------------------------------------------------------------------
# checking the availability of system

Echo_Banner "Rainbond v$RBD_VERSION"

check_func(){
    Echo_Info "Check func."
    ./scripts/check.sh $@
}

init_config(){
    if [ ! -f $INIT_FILE ];then
        Echo_Info "Init rainbond configure."
        ./scripts/init_sls.sh && touch $INIT_FILE
    fi
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
      if $( grep 'install-type: online' ${MAIN_CONFIG} >/dev/null );then
        REG_Status || return 0
      fi
        uuid=$(salt '*' grains.get uuid | grep "-" | awk '{print $1}')
        notready=$(grctl  node list | grep $uuid | grep false)
        if [ "$notready" != "" ];then
            grctl node up $uuid
        fi
        Echo_Info "install successfully"
        grctl show
    fi
}

Offline_Prepare(){
    if [ ! -f $OFFLINE_FILE ];then
    Echo_Info "Prepare install rainbond offline."
    ./scripts/prepare_install.sh && touch $OFFLINE_FILE
    fi
}

help_func(){
    echo "help:"
    echo "check   --- check cmd "
    echo "offline --- work in offline env cmd"
    echo "install --- install cmd "
    echo "dev     --- ignore check install cmd "
    echo ""
}

case $1 in
    check)
        check_func ${@:2} && init_config
    ;;
    install)
        #do not check the internet when install offline
        if $( grep 'install-type: online' ${MAIN_CONFIG} >/dev/null );then
        check_func && init_config && install_func ${@:2}
        else
        init_config && install_func
        fi
    ;;
    dev)
        check_func force && init_config && install_func ${@:2}
    ;;
    offline)
        Offline_Prepare && init_config && install_func
    ;;
    *)
        help_func
    ;;
esac
