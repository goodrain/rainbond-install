#!/bin/bash

IP=$(cat /opt/rainbond/envs/etcd.sh | awk -F= '{print $2}')

curl http://{{ pillar['master-private-ip'] }}:2379/v2/members -XPOST -H "Content-Type: application/json" -d '{"peerURLs": ["http://'$IP':2380"]}'
