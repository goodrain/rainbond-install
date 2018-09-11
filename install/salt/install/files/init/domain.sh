#!/bin/bash

DOMAIN_IP=$1
DOMAIN_UUID={{ grains['uuid'] }}
DOMAIN_LOG={{ pillar['rbd-path'] }}/.domain.log
DOMAIN_API="http://domain.grapps.cn/domain"
AUTH={{ pillar['secretkey'] }}
DOMAIN_TYPE=False
INSTALL_TYPE={{ pillar['install-type'] }}

if [[ "$INSTALL_TYPE" != "offline" ]];then
    curl --connect-timeout 20  -d 'ip='"$DOMAIN_IP"'&uuid='"$DOMAIN_UUID"'&type='"$DOMAIN_TYPE"'&auth='"$AUTH"'' -X POST  $DOMAIN_API/new > $DOMAIN_LOG
    cat > /tmp/.lock.domain <<EOF
curl --connect-timeout 20  -d 'ip='"$DOMAIN_IP"'&uuid='"$DOMAIN_UUID"'&type='"$DOMAIN_TYPE"'&auth='"$AUTH"'' -X POST  $DOMAIN_API/new > $DOMAIN_LOG
EOF
fi

[ -f $DOMAIN_LOG ] && wilddomain=$(cat $DOMAIN_LOG )

if [[ "$wilddomain" == *grapps.cn ]];then
    echo "wild-domain: $wilddomain"
    sed -i -r  "s/(^domain: ).*/\1$wilddomain/" /srv/pillar/rainbond.sls
else
    echo "not generate, will use example"
    sed -i -r  "s/(^domain: ).*/\1paas.example.com/" /srv/pillar/rainbond.sls
fi