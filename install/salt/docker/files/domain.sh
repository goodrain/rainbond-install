#!/bin/bash

DOMAIN_IP=$1
DOMAIN_UUID={{ grains['uuid'] }}
DOMAIN_LOG={{ pillar['rbd-path'] }}/.domain.log
DOMAIN_API="http://domain.grapps.cn/domain/"

if [ -f "/tmp/.goodrain" ];then
    DOMAIN_TYPE="True"
else
    DOMAIN_TYPE="False"
fi

grep "domain" /srv/pillar/custom.sls
if [[ $? -ne 0 ]];then
    curl -d 'ip=$DOMAIN_IP&uuid=$DOMAIN_UUID&type=$DOMAIN_TYPE&auth=' -X POST  $DOMAIN_API/new > $DOMAIN_LOG
    echo "domain: $(cat {{ pillar['rbd-path'] }}/.domain.log)" >> /srv/pillar/custom.sls
else
    echo "domain exist"
fi
