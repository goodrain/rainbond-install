#!/bin/bash

IP=$1

function domain() {
    EX_DOMAIN=$(cat {{ pillar['rbd-path'] }}/.domain.log)
    grep "grapps.cn" {{ pillar['rbd-path'] }}/.domain.log > /dev/null
    if [ "$?" -ne 0 ];then
        echo "DOMAIN NOT ALLOW"
    else
        /usr/local/bin/domain-cli --newip $IP > /dev/null
        if [ $? -eq 0 ];then
            echo "domain change Success!!!"
        else
            echo "domain change error!!!"
        fi
    fi
}

case $1 in
    *)
        domain
    ;;
esac