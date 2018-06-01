#!/bin/bash

exec /usr/bin/docker \
  run \
  --privileged \
  --restart=always \
  --net=host \
  --name etcd-proxy \
  {{ pillar['public-image-domain'] }}/{{pillar['etcd']['proxy']['image']}}:{{pillar['etcd']['proxy']['version']}} \
  /usr/local/bin/etcd \
  grpc-proxy start \
  --endpoints=$MASTER_IP \
  --listen-addr=127.0.0.1:2379