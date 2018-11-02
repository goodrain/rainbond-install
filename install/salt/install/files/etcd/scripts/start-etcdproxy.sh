#!/bin/bash

[ -z "$MASTER_IP" ] && MASTER_IP={{ pillar['vip'] }}

CLUSTER_MASTER=""

for node in $(echo $MASTER_IP | tr "," "\n" | sort -u)
do
  member=${node#*//}
	if [ -z $CLUSTER_MASTER ];then
		CLUSTER_MASTER=$member
	else
		CLUSTER_MASTER="$CLUSTER_MASTER,$member"
	fi
done

exec /usr/bin/docker \
  run \
  --privileged \
  --restart=always \
  --net=host \
  --name etcd-proxy \
  {{ pillar['private-image-domain'] }}/{{ pillar['etcd']['proxy']['image']}}:{{pillar['etcd']['proxy']['version'] }} \
  /usr/local/bin/etcd \
  grpc-proxy start \
  --endpoints=${CLUSTER_MASTER} \
  --listen-addr=127.0.0.1:2379