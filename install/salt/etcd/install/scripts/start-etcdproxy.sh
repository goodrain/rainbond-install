#!/bin/bash

exec /usr/bin/docker \
  run \
  --privileged \
  --restart=always \
  --net=host \
  --name etcd-proxy \
  goodrain.me/etcd:v3.2.13 \
  /usr/local/bin/etcd \
  grpc-proxy start \
  --endpoints=$MASTER_IP \
  --listen-addr=127.0.0.1:2379