#!/bin/bash

curl http://{{ pillar['master-private-ip'] }}:2379/v2/members -XPOST -H "Content-Type: application/json" -d '{"peerURLs": ["http://{{ grains['fqdn_ip4'][0] }}:2380"]}'
