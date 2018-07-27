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
#           ADD:  offline
#   DESCRIPTION: add a parameter  offline  ,it is use for install a compute node without internet. 
#
#
#======================================================================================================================

# debug
[[ $DEBUG ]] && set -x

[ -f "common.sh" ] && cd ..

. scripts/common.sh

init_func(){
    Echo_Info "Init compute node config."
    Echo_Info "change hostname"
    if [ "$1" = "single" ];then
        echo $@
        if [ "$#" -lt 4 ];then
            Echo_Error "need 4 args at least\n like: [$PWD] ./scripts/compute.sh init single <hostname> <ip> <passwd/key> <type>"
        fi
        grep "$2" /etc/salt/roster > /dev/null
        if [ "$?" -ne 0 ];then
            if [ -z "$5" ];then
                cat >> /etc/salt/roster <<EOF
$2:
  host: $3
  user: root
  passwd: $4
  tty: True
  sudo: True
  port: 22
EOF
        else
            cat >> /etc/salt/roster <<EOF
$2:
  host: $3
  user: root
  priv: ${4:-/root/.ssh/id_rsa}
  tty: True
  sudo: True
  port: 22
EOF
        fi
        salt-ssh -i $2 state.sls init.init_node

        uuid=$(salt-ssh -i $2 grains.item uuid | egrep '[a-zA-Z0-9]-' | awk '{print $1}')
        grep "$3" /etc/hosts > /dev/null
        [ "$?" -ne 0 ] && echo "$3 $2 $uuid" >> /etc/hosts
        else
            Echo_EXIST $2["$3"]
        fi
        bash scripts/node_update_hosts.sh $uuid $3 add
    elif [ "$1" = "multi" ];then
        if [ "$#" -ne 3 ];then
            Echo_Error "need 3 args\n like: [$PWD] ./scripts/compute.sh init multi <ip.txt path> <passwd>"
        fi
        salt-ssh -i -E "compute" state.sls init.init_node
    else
        Echo_Error "not support ${1:-null}"
    fi
}

check_func(){
    Echo_Info "Check Compute func."
}

install_compute_func(){
    fail_num=0
    step_num=1
    all_steps=$(echo ${COMPUTE_MODULES} | tr ' ' '\n' | wc -l)
    Echo_Info "will install compute node."
    if [ ! -z "$1" ];then
        salt-ssh -i $1 state.sls salt.install
        sleep 12
        Echo_Info "waiting to start salt-minions "
        for module in ${COMPUTE_MODULES}
        do
            Echo_Info "Start install $module(step: $step_num/$all_steps) ..."
            
            if ! (salt $1 state.sls $module);then
                ((fail_num+=1))
                break
            fi
            ((step_num++))
        done
        
    else
        salt-ssh -i -E "compute" state.sls salt.install
        sleep 12
        Echo_Info "waiting to start salt-minions"
        for module in ${COMPUTE_MODULES}
        do
            Echo_Info "Start install $module(step: $step_num/$all_steps) ..."
            
            if ! (salt -E "compute" state.sls $module);then
                ((fail_num+=1))
                break
            fi
            ((step_num++))
        done
    fi
    
    if [ "$fail_num" -eq 0 ];then
        dc-compose restart rbd-webcli
        Echo_Info "install compute node successfully"
        if [ ! -z "$1" ];then
              uuid=$(salt-ssh -i $1 grains.item uuid | egrep '[a-zA-Z0-9]-' | awk '{print $1}')
              for ((i=1;i<=15;i++ )); do
                sleep 1
                grctl node list | grep "$uuid" > /dev/null 2>&1
                [ "$?" -eq 0 ] && (
                 grctl node up $uuid
                 Echo_Info "compute node($uuid) added to the cluster"
                ) && break
              done
            # Echo_Info "compute node($uuid) has been added to the cluster"
        else
            Echo_Info "you need up compute node"
        fi
    fi
}

help_func(){
    Echo_Info "help"
    Echo_Info "init"
    echo "args: single <hostname> <ip>  <password/key-path> <type:ssh>"
    Echo_Info "install <hostname>"
    Echo_Info "offline"
    echo "args: single <hostname> <ip>  <password/key-path>"

}

case $1 in
    init)
        init_func ${@:2}
    ;;
    install)
        install_compute_func $2 
    ;;
    offline)
        init_func ${@:2} && install_compute_func $3
    ;;
    *)
        help_func
    ;;
esac


