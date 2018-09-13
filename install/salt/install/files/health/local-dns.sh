#!/bin/bash

LOCAL_DNS="{{ grains['mip'][0] }}"
MASTER_DNS="{{ pillar['master-private-ip'] }}"
DEFALUT_DNS="{{ pillar.dns.get('current','114.114.114.114') }}"

grep $LOCAL_DNS /etc/resolv.conf >/dev/null 2>&1
if [ "$?" -eq 0 ];then
    exit 0
else
    cat > /etc/resolv.conf <<EOF
nameserver $LOCAL_DNS
nameserver $MASTER_DNS
nameserver $DEFALUT_DNS
EOF
    exit 1
fi

