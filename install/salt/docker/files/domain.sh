#!/bin/bash
grep "domain" /srv/pillar/goodrain.sls
if [[ $? -ne 0 ]];then
    echo "domain: $(cat {{ pillar['rbd-path'] }}/.domain.log)" >> /srv/pillar/goodrain.sls
else
    echo "domain exist"
fi
