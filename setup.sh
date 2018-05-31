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
<<<<<<< HEAD
. scripts/common.sh "$1"
=======
>>>>>>> v3.6

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
<<<<<<< HEAD
        ./scripts/init_sls.sh $1 && touch $INIT_FILE
=======

        
        ./scripts/init_sls.sh && touch $INIT_FILE
>>>>>>> v3.6
    fi
}

install_func(){
    fail_num=0
    Echo_Info "will install manage node."
#judgment below uses for offline env : del docker from MANAGE_MODULES ( changed by guox 2018.5.18 ).
    [[ "$@" == "offline" ]] && export MANAGE_MODULES="${MANAGE_MODULES%%docker*}${MANAGE_MODULES##*docker}"
    for module in ${MANAGE_MODULES}
    do
        echo "Start install $module ..."
        if ! (salt "*" state.sls $module);then
            ((fail_num+=1))
            break
        fi
    done

    if [ "$fail_num" -eq 0 ];then
        REG_Status $1 || return 0
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
        check_func && init_config && install_func ${@:2}
    ;;
    dev)
        check_func force && init_config && install_func ${@:2}
    ;;
    offline)
        Offline_Prepare && init_config offline && install_func offline
    ;;
    *)
        help_func
    ;;
esac
