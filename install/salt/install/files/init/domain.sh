#!/bin/bash

DOMAIN_IP=$1
DOMAIN_UUID={{ grains['uuid'] }}
DOMAIN_LOG={{ pillar['rbd-path'] }}/.domain.log
DOMAIN_API="http://domain.grapps.cn/domain"
AUTH={{ pillar['secretkey'] }}
DOMAIN_TYPE=False
DOMAIN_TYPE={{ pillar['install-type'] }}

if [[ "$DOMAIN_TYPE" != "offline" ]];then
    curl -d 'ip='"$DOMAIN_IP"'&uuid='"$DOMAIN_UUID"'&type='"$DOMAIN_TYPE"'&auth='"$AUTH"'' -X POST  $DOMAIN_API/new > $DOMAIN_LOG
fi

[ -f $DOMAIN_LOG ] && wilddomain=$(cat $DOMAIN_LOG )

if [[ "$wilddomain" == *grapps.cn ]];then
    echo "wild-domain: $wilddomain"
    sed -i -r  "s/(^domain: ).*/\1$wilddomain/" /srv/pillar/rainbond.sls
else
    echo "not generate, will use example"
    sed -i -r  "s/(^domain: ).*/\1paas.example.com/" /srv/pillar/rainbond.sls
fi