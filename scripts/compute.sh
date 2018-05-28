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
#
#           ADD: $6 : offline
#   DESCRIPTION: add a parameter  offline in $6 ,it is use for install a compute node without internet. 
#
#
#======================================================================================================================

# debug
[[ $DEBUG ]] && set -x

. scripts/common.sh $6

init_func(){
    Echo_Info "Init compute node config."
    if [ "$1" = "single" ];then
        echo $@
        if [ "$#" -ne 4 -a "$#" -ne 5 ];then
            Echo_Error "need 4 args at least\n like: [$PWD] ./scripts/compute.sh init single <hostname> <ip> <passwd> [offline]"
        fi
        grep "$2" /etc/salt/roster > /dev/null
        if [ "$?" -ne 0 ];then
            cat >> /etc/salt/roster <<EOF
$2:
  host: $3 
  user: root         
  passwd: $4  
  sudo: True
  port: 22         
EOF
        grep "$3" /etc/hosts > /dev/null
        [ "$?" -ne 0 ] && echo "$3 $2" >> /etc/hosts
        else
            Echo_EXIST $2["$3"]
        fi
    elif [ "$1" = "multi" ];then
        if [ "$#" -ne 3 ];then
            Echo_Error "need 3 args\n like: [$PWD] ./scripts/compute.sh init multi <ip.txt path> <passwd>"
        fi
    else
        Echo_Error "not support ${1:-null}"
    fi
    Echo_Info "change hostname"
    #judgment below uses for offline env : init compute node offline ( changed by guox 2018.5.22 ).
    if [[ "$5" == "offline" ]];then
      salt-ssh -i -E 'compute' -r "mkdir -p ~/rainbond-install/install"
      scp -r /root/rainbond-install/install/pkgs $3:/root/rainbond-install/install
      scp /etc/yum.repos.d/rainbond_local.repo $3:/etc/yum.repos.d
      salt-ssh -i -E "compute" state.sls init.compute_offline
    else
    salt-ssh -i -E "compute" state.sls init.compute
    fi
}

check_func(){
    Echo_Info "Check Compute func."
    # Todo
    # ./scripts/check.sh $@
}

install_compute_func(){
    fail_num=0
    Echo_Info "will install compute node."
    #judgment below uses for offline env : do not install salt-minion through internet ( changed by guox 2018.5.18 ).
    if [ "$1" != "offline" ];then
      salt-ssh -i -E "compute" state.sls minions.install
    else
      #del docker from ${COMPUTE_MODULES} : do not install docker through internet
      Compute_Modules=${COMPUTE_MODULES} | sed 's/docker//g'
      export COMPUTE_MODULES=$Compute_Modules
      #install docker without internet
      . scripts/prepare_install.sh compute
      salt-ssh -i -E "compute" state.sls minions.install_offline
    fi
    sleep 12
    Echo_Info "waiting for salt-minions start"
    for module in ${COMPUTE_MODULES}
    do
        Echo_Info "Start install $module ..."
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
    Echo_Info "help"
    Echo_Info "init"
    echo "args: single <hostname> <ip>  <password/key-path>"
    echo "args: multi <ip.txt path> <password/key-path>"
    Echo_Info "check"
    Echo_Info "install"
}

case $1 in
    init)
        init_func ${@:2}
    ;;
    check)
        check_func ${@:2}
    ;;
    # Todo 
    #install)
    #    check_func && install_compute_func
    #;;
    #dev)
    #    check_func force && install_compute_func
    #;;
    install)
        install_compute_func $6
    ;;
    *)
        help_func
    ;;
esac


