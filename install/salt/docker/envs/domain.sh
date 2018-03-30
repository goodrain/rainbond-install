#!/bin/bash

echo "domain: $(cat {{ pillar['rbd-path'] }}/.domain.log)" >> {{ pillar['install-script-path'] }}/rainbond-install/install/pillar/system_info.sls