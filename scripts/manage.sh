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

MANAGE_MODULES="common \
storage \
docker \
image \
base \
master \
worker"

#================================= base func =======================
if [ $(( $(tput colors 2>/dev/null) )) -ge 8 ];then
            # Enable colors
            TPUT_RESET="$(tput sgr 0)"
            TPUT_BLACK="$(tput setaf 0)"
            TPUT_RED="$(tput setaf 1)"
            TPUT_GREEN="$(tput setaf 2)"
            TPUT_YELLOW="$(tput setaf 3)"
            TPUT_BLUE="$(tput setaf 4)"
            TPUT_PURPLE="$(tput setaf 5)"
            TPUT_CYAN="$(tput setaf 6)"
            TPUT_WHITE="$(tput setaf 7)"
            TPUT_BGBLACK="$(tput setab 0)"
            TPUT_BGRED="$(tput setab 1)"
            TPUT_BGGREEN="$(tput setab 2)"
            TPUT_BGYELLOW="$(tput setab 3)"
            TPUT_BGBLUE="$(tput setab 4)"
            TPUT_BGPURPLE="$(tput setab 5)"
            TPUT_BGCYAN="$(tput setab 6)"
            TPUT_BGWHITE="$(tput setab 7)"
            TPUT_BOLD="$(tput bold)"
            TPUT_DIM="$(tput dim)"
            TPUT_UNDERLINED="$(tput smul)"
            TPUT_BLINK="$(tput blink)"
            TPUT_INVERTED="$(tput rev)"
            TPUT_STANDOUT="$(tput smso)"
            TPUT_BELL="$(tput bel)"
            TPUT_CLEAR="$(tput clear)"
fi

Echo_Failed() {
    printf >&2 "${TPUT_BGRED}${TPUT_WHITE}${TPUT_BOLD} FAILED ${TPUT_RESET} ${*} \n\n"
}

Echo_Error() {
    printf >&2 "${TPUT_BGRED}${TPUT_WHITE}${TPUT_BOLD} FAILED ${TPUT_RESET} ${*} \n\n"
    exit 1
}

Echo_EXIST() {
    printf >&2 "${TPUT_BGRED}${TPUT_WHITE}${TPUT_BOLD} EXIST ${TPUT_RESET} ${*} \n\n"
}

Echo_Info() {
    echo >&2 " --- ${TPUT_DIM}${TPUT_BOLD}${*}${TPUT_RESET} --- "
}

Echo_Ok() {
   printf >&2 "${TPUT_BGGREEN}${TPUT_WHITE}${TPUT_BOLD} OK ${TPUT_RESET} ${*} \n\n"
}

#===================================================================================

init(){
    Echo_Info "Init manage node config."
    Echo_Info "change hostname"

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
           
        grep "$1" /etc/hosts > /dev/null
        [ "$?" -ne 0 ] && echo "$2 $1" >> /etc/hosts
        else
            Echo_EXIST $1["$2"]
        fi
        salt-ssh -i $1 state.sls common.init_node
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
    #salt "*" saltutil.sync_modules
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

case $1 in
    *)
        init $@
        update_data
        install $1
    ;;
esac


