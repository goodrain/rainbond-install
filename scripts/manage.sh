#!/bin/bash
#======================================================================================================================
#
#          FILE: manage.sh
#
#   DESCRIPTION: Install Manage Node
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

init(){
    Echo_Info "Init manage node config."
    Echo_Info "change hostname"
    if [ "$1" = "single" ];then
        echo $@
        if [ "$#" -lt 4 ];then
            Echo_Error "need 4 args at least\n like: [$PWD] ./scripts/manage.sh init single <hostname> <ip> <passwd/key> <type>"
        fi
        grep "$2" /etc/salt/roster > /dev/null
        if [ "$?" -ne 0 ];then
            if [ -z "$5" ];then
                cat >> /etc/salt/roster <<EOF
$2:
  host: $3
  user: root
  passwd: $4
  sudo: True
  port: 22
EOF
        else
            cat >> /etc/salt/roster <<EOF
$2:
  host: $3
  user: root
  priv: ${4:-/root/.ssh/id_rsa}
  sudo: True
  port: 22
EOF
        fi     
        grep "$3" /etc/hosts > /dev/null
        [ "$?" -ne 0 ] && echo "$3 $2" >> /etc/hosts
        else
            Echo_EXIST $2["$3"]
        fi
            
        salt-ssh -i $2 state.sls init.init_node
    elif [ "$1" = "multi" ];then
        if [ "$#" -ne 3 ];then
            Echo_Error "need 3 args\n like: [$PWD] ./scripts/manage.sh init multi <ip.txt path> <passwd>"
        fi
        salt-ssh -i -E "manage" state.sls init.init_node
    else
        Echo_Error "not support ${1:-null}"
    fi
}

install(){
    fail_num=0
    Echo_Info "will install manage node."
    if [ ! -z "$1" ];then
        salt-ssh -i $1 state.sls salt.install
        for module in ${MANAGE_MODULES}
        do
            Echo_Info "Start install $module ..."
            
            if ! (salt $1 state.sls $module);then
                ((fail_num+=1))
                break
            fi
        done
    else
        salt-ssh -i -E "manage" state.sls salt.install
        for module in ${MANAGE_MODULES}
        do
            Echo_Info "Start install $module ..."
            
            if ! (salt -E "manage" state.sls $module);then
                ((fail_num+=1))
                break
            fi
        done
    fi
      sleep 12
      Echo_Info "waiting for salt-minions start"
    if [ "$fail_num" -eq 0 ];then
        Echo_Info "install manage node successfully"
    fi
}

help(){
    Echo_Info "help"
    Echo_Info "init"
    echo "args: single <hostname> <ip>  <password/key-path> <type:ssh>"
    echo "args: multi <ip.txt path> <password/key-path>"
    Echo_Info "check"
    Echo_Info "install"
    Echo_Info "offline"
    echo "args: single <hostname> <ip>  <password/key-path>"

}

case $1 in
    init)
        init ${@:2}
    ;;
    install)
        install $2 
    ;;
    offline)
        init ${@:2} && install ${@:2}
    ;;
    *)
        help
    ;;
esac


