#!/bin/bash
#======================================================================================================================
#
#          FILE: install_salt.sh
#
#   DESCRIPTION: Install
#
#          BUGS: https://github.com/goodrain/rainbond-install/issues
#
#     COPYRIGHT: (c) 2018 by the Goodrain Delivery Team.
#
#       LICENSE: Apache 2.0
#       CREATED: 06/04/2018 11:59:37 PM
#======================================================================================================================
[[ $DEBUG ]] && set -x

cd ../

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

case $1 in
    *)
        check_func force && init_config
    ;;
esac
