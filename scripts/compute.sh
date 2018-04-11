#!/bin/bash
#======================================================================================================================
#
#          FILE: compute.sh
#
#   DESCRIPTION: Install Compute Node
#
#          BUGS: https://github.com/goodrain/rainbond-install/issues
#
#     COPYRIGHT: (c) 2018 by the Goodrain Delivery Team.
#
#       LICENSE: Apache 2.0
#       CREATED: 07/04/2018 10:49:37 AM
#======================================================================================================================

# debug
[[ $DEBUG ]] && set -x

. scripts/common.sh

init_func(){
    Echo_Info "Init compute node config."

}

check_func(){
    Echo_Info "Check Compute func."
}

install_compute_func(){
    fail_num=0
    Echo_Info "will install compute node."

    for module in ${COMPUTE_MODULES}
    do
        echo "Start install $module ..."
        if ! (salt -E "compute" state.sls $module);then
            ((fail_num+=1))
            break
        fi
    done

    if [ "$fail_num" -eq 0 ];then
        Echo_Info "install compute node successfully"
    fi
}

help_func(){
    Echo_Info "help func"
    Echo_Info "check   --- check cpu&mem&network "
    Echo_Info "init --- init compute node config "
    echo "args: single <ip> <hostname> <password/key-path>"
    echo "args: multi <ip.txt path> <password/key-path>"
    Echo_Info "install --- install compute node "
}

case $1 in
    check)
        check_func ${@:2}
    ;;
    init)
        init ${@:2}
    ;;
    install)
        install_compute_func
    ;;
    *)
        help_func
    ;;
esac


