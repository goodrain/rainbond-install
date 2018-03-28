#!/bin/sh

KUBE_CONTROLLER_MANAGER_OPTS="--master=127.0.0.1:8181 \
--pod-eviction-timeout=3m0s \
--custom-config={{ pillar['rbd-path'] }}/kubernetes/k8s/custom.conf \
--leader-elect=true \
--logtostderr=true \
--address=127.0.0.1 \
--v=2 \
--cluster-name=kubernetes \
--cluster-signing-cert-file={{ pillar['rbd-path'] }}/kubernetes/ssl/ca.pem \
--cluster-signing-key-file={{ pillar['rbd-path'] }}/kubernetes/ssl/ca-key.pem \
--service-account-private-key-file={{ pillar['rbd-path'] }}/kubernetes/ssl/ca-key.pem \
--root-ca-file={{ pillar['rbd-path'] }}/kubernetes/ssl/ca.pem"

exec /usr/bin/docker \
  run \
  --privileged \
  --restart=always \
  --net=host \
  --name kube-controller-manager \
  --volume={{ pillar['rbd-path'] }}/kubernetes/k8s:{{ pillar['rbd-path'] }}/kubernetes/k8s \
  --volume={{ pillar['rbd-path'] }}/kubernetes:{{ pillar['rbd-path'] }}/kubernetes \
  rainbond/kube-controller-manager:v1.6.4 \
  $KUBE_CONTROLLER_MANAGER_OPTS