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
    # <hostname> <ip>  <password/key-path> <type:ssh>
        grep "$1" /etc/salt/roster > /dev/null
        if [ "$?" -ne 0 ];then
            if [ -z "$4" ];then
                cat >> /etc/salt/roster <<EOF
$1:
  host: $2
  user: root
  passwd: $3
  sudo: True
  tty: True
  port: 22
EOF
        else
            cat >> /etc/salt/roster <<EOF
$1:
  host: $2
  user: root
  priv: ${3:-/root/.ssh/id_rsa}
  sudo: True
  tty: True
  port: 22
EOF
        fi
        salt-ssh -i $1 state.sls common.init_node

        uuid=$(salt-ssh -i $1 grains.item uuid | egrep '[a-zA-Z0-9]-' | awk '{print $1}')
        grep "$2" /etc/hosts > /dev/null
        [ "$?" -ne 0 ] && echo "$2 $1 $uuid" >> /etc/hosts
        else
            Echo_EXIST $2["$3"]
        fi
        bash scripts/node_update_hosts.sh $uuid $2 add
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
        systemctl restart kube-apiserver
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
    Echo_Info "<hostname> <ip>  <password/key-path> <type:ssh>"
}

case $1 in
    *)
        init_func $@
        install_compute_func $1
    ;;
esac


