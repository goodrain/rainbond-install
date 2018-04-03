#!/bin/bash
grep "domain" /srv/pillar/system_info.sls
if [[ $? -ne 0 ]];then
    echo "domain: $(cat {{ pillar['rbd-path'] }}/.domain.log)" >> /srv/pillar/system_info.sls
else
    echo "domain exist"
fi