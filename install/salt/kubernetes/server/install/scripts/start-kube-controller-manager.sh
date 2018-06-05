#!/bin/sh

KUBE_CONTROLLER_MANAGER_OPTS="--master=127.0.0.1:8181 \
--pod-eviction-timeout=3m0s \
--custom-config={{ pillar['rbd-path'] }}/etc/kubernetes/custom.conf \
--leader-elect=true \
--logtostderr=true \
--address=127.0.0.1 \
--v=2 \
--cluster-name=kubernetes \
--cluster-signing-cert-file={{ pillar['rbd-path'] }}/etc/kubernetes/ssl/ca.pem \
--cluster-signing-key-file={{ pillar['rbd-path'] }}/etc/kubernetes/ssl/ca-key.pem \
--service-account-private-key-file={{ pillar['rbd-path'] }}/etc/kubernetes/ssl/ca-key.pem \
--root-ca-file={{ pillar['rbd-path'] }}/etc/kubernetes/ssl/ca.pem"

exec /usr/bin/docker \
  run \
  --privileged \
  --restart=always \
  --net=host \
  --name kube-controller-manager \
  --volume={{ pillar['rbd-path'] }}/etc/kubernetes:{{ pillar['rbd-path'] }}/etc/kubernetes \
  {{ pillar['public-image-domain'] }}/{{pillar['kubernetes']['manager']['image']}}:{{pillar['kubernetes']['manager']['version']}} \
  $KUBE_CONTROLLER_MANAGER_OPTS