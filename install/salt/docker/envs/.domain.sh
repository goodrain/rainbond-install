#!/bin/bash

IP=$1

function domain() {
    EX_DOMAIN=$(cat /opt/rainbond/.domain.log)
    grep "goodrain.org" /opt/rainbond/.domain.log > /dev/null
    if [ "$?" -ne 0 ];then
        echo "DOMAIN NOT ALLOW"
    else
        docker run --rm rainbond/archiver:domain_v2 update --ip $IP --domain $EX_DOMAIN
        if [ $? -eq 0 ];then
            echo "domain change Success!!!"
            docker rmi rainbond/archiver:domain_v2
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