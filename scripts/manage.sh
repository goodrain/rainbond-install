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
  tty: True
  port: 22
EOF
        else
            cat >> /etc/salt/roster <<EOF
$2:
  host: $3
  user: root
  priv: ${4:-/root/.ssh/id_rsa}
  sudo: True
  tty: True
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
update_data(){
    # manage01
    [ -f "/tmp/mnode" ] && rm -rf /tmp/mnode
    [ -f "/tmp/minfo" ] && rm -rf /tmp/minfo
    [ -f "/tmp/mip" ] && rm -rf /tmp/mip
    cat /etc/salt/roster | grep manage | awk -F: '{print $1}' > /tmp/mnode
    yq r /srv/pillar/rainbond.sls etcd.proxy > /tmp/etcd-proxy.sls
    cat > /tmp/petcd.sls <<EOF
etcd:
  proxy:
EOF
    cat /tmp/etcd-proxy.sls | while read -r line
    do
    cat >> /tmp/petcd.sls <<EOF
    $line
EOF
done

    yq r /srv/pillar/rainbond.sls etcd.server > /tmp/etcd.sls
    yq d /tmp/etcd.sls 'members' > /tmp/sdetcd.sls 
    cat > /tmp/detcd.sls <<EOF
etcd:
  server:
EOF
    cat /tmp/sdetcd.sls | while read -r line
    do
    if [[ "$line" =~ "host" ]];then
        cat >> /tmp/detcd.sls <<EOF
      $line
EOF
    else
        cat >> /tmp/detcd.sls <<EOF
    $line
EOF
    fi
    done
    echo "    members:" >> /tmp/detcd.sls
    cat /tmp/mnode | while read -r line
    do
    ip=$(yq r /etc/salt/roster $line.host)
    cat >> /tmp/detcd.sls <<EOF
    - host: $ip
      name: $line
      port: 2379
EOF
    done
    yq m /tmp/petcd.sls /tmp/detcd.sls > /tmp/all.sls
    yq w -i -s /tmp/all.sls /srv/pillar/rainbond.sls 


    cat /tmp/mnode | while read line
    do
        yq r /etc/salt/roster $line.host | awk '{print $1}' >> /tmp/mip
    done
    ETCD_ENDPOINT=""
    LB_ENDPOINT=""
    for node in $(cat /tmp/mip | sort -u)
    do 
        member="http://$node:2379"
        if [ -z "$ETCD_ENDPOINT" ];then
        ETCD_ENDPOINT="$member"
        else
            ETCD_ENDPOINT="$ETCD_ENDPOINT,$member"
        fi
        lb="http://$node:10002"
        if [ -z "$LB_ENDPOINT" ];then
        LB_ENDPOINT="$lb"
        else
            LB_ENDPOINT="$LB_ENDPOINT-$lb"
        fi
    done
    yq w -i /srv/pillar/rainbond.sls  etcd-endpoints $ETCD_ENDPOINT
    yq w -i /srv/pillar/rainbond.sls  lb-endpoints $LB_ENDPOINT
}
install(){
    fail_num=0
    Echo_Info "update salt modules"
    salt "*" saltutil.sync_modules
    Echo_Info "will install manage node."

    minion_status=1
    if [ ! -z "$1" ];then
        salt-ssh -i $1 state.sls salt.install
        Echo_Info "Waiting to start $1 salt-minion."
        for ((i=1;i<=20;i++ )); do
            echo -e -n "."
            sleep 1
            uuid=$(timeout 3 salt $1 grains.get uuid | grep '-' | awk '{print $1}')
            [ ! -z $uuid ] && minion_status=0 && break
        done
        if [ "$minion_status" == 0 ];then
            for module in ${MANAGE_MODULES}
            do
                Echo_Info "Start install $module ..."
                
                if ! (salt $1 state.sls $module);then
                    ((fail_num+=1))
                    break
                fi
            done
        fi

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
    if [ "$fail_num" -eq 0 ];then
        Echo_Info "install manage node successfully"
    else
        Echo_Error "reinstall manage node"
    fi
}

help(){
    Echo_Info "help"
    Echo_Info "init"
    echo "args: single <hostname> <ip>  <password/key-path> <type:ssh>"
    echo "args: multi <ip.txt path> <password/key-path>"
    Echo_Info "update"
    Echo_Info "install"
    Echo_Info "offline"
    echo "args: single <hostname> <ip>  <password/key-path>"

}

case $1 in
    init)
        init ${@:2}
    ;;
    update)
        update_data
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


