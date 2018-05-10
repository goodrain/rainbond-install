#!/bin/bash
grep "domain" /srv/pillar/custom.sls
if [[ $? -ne 0 ]];then
    echo "domain: $(cat {{ pillar['rbd-path'] }}/.domain.log)" >> /srv/pillar/custom.sls
else
    echo "domain exist"
fi
