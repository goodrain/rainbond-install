#!/bin/bash

DOMAIN_IP=$1
DOMAIN_UUID={{ grains['uuid'] }}
DOMAIN_LOG={{ pillar['rbd-path'] }}/.domain.log
DOMAIN_API="http://domain.grapps.cn/domain"
AUTH={{ pillar['secretkey'] }}
DOMAIN_TYPE=False

grep "domain" /srv/pillar/custom.sls
if [[ $? -ne 0 ]];then
    curl -d 'ip='"$DOMAIN_IP"'&uuid='"$DOMAIN_UUID"'&type='"$DOMAIN_TYPE"'&auth='"$AUTH"'' -X POST  $DOMAIN_API/new > $DOMAIN_LOG
    echo " " >> /srv/pillar/custom.sls
    grep "grapps.cn" /opt/rainbond/.domain.log >/dev/null 
    if [[ "$?" -eq 0 ]];then
        echo "domain: $(cat /opt/rainbond/.domain.log)" >> /srv/pillar/custom.sls
    else
        echo "not generate, will use example"
        echo "domain: www.example.com" >> /srv/pillar/custom.sls
    fi
else
    echo "domain exist"
fi
