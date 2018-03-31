#!/bin/bash
grep "domain" {{ pillar['install-script-path'] }}/install/pillar/system_info.sls
if [[ $? -ne 0 ]];then
    echo "domain: $(cat {{ pillar['rbd-path'] }}/.domain.log)" >> {{ pillar['install-script-path'] }}/install/pillar/system_info.sls
else
    echo "domain exist"
fi