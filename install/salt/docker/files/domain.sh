#!/bin/bash

wilddomain=$(cat {{ pillar['rbd-path'] }}/.domain.log)
echo "wild-domain: $wilddomain"

sed -i -r  "s/(domain: ).*/\1$wilddomain/" /srv/pillar/rainbond.sls