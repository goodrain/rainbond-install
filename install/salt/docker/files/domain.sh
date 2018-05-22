#!/bin/bash
grep "domain" /srv/pillar/rainbond.sls
if [[ $? -ne 0 ]];then
    wilddomain=$(cat {{ pillar['rbd-path'] }}/.domain.log)
    sed -i -r  "s/(domain: ).*/\1$wilddomain/" /srv/pillar/rainbond.sls
else
    echo "domain exist"
fi
