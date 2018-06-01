#!/bin/sh

KUBE_SCHEDULER_OPTS="--logtostderr=true \
--v=5 \
--master=127.0.0.1:8181 \
--custom-config={{ pillar['rbd-path'] }}/etc/kubernetes/custom.conf \
--leader-elect=true \
"

exec /usr/bin/docker \
  run \
  --privileged \
  --restart=always \
  --net=host \
  --name kube-scheduler \
  --volume={{ pillar['rbd-path'] }}/etc/kubernetes/kubecfg:{{ pillar['rbd-path'] }}/etc/kubernetes/kubecfg \
  {{ pillar['public-image-domain'] }}/{{pillar['kubernetes']['schedule']['image']}}:{{pillar['kubernetes']['schedule']['version']}} \  
  $KUBE_SCHEDULER_OPTS