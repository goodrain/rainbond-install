#!/bin/sh
KUBE_APISERVER_OPTS="--insecure-bind-address=127.0.0.1 \
--insecure-port=8181 \
--advertise-address=0.0.0.0 --bind-address=0.0.0.0 \
--etcd_servers=http://${ETCD_ADDRESS:-127.0.0.1:2379} \
--admission-control=ServiceAccount,NamespaceLifecycle,NamespaceExists,LimitRanger,ResourceQuota \
--authorization-mode=RBAC \
--runtime-config=rbac.authorization.k8s.io/v1beta1 \
--experimental-bootstrap-token-auth \
--token-auth-file={{ pillar['rbd-path'] }}/kubernetes/kubecfg/token.csv \
--tls-cert-file={{ pillar['rbd-path'] }}/kubernetes/ssl/kubernetes.pem \
--tls-private-key-file={{ pillar['rbd-path'] }}/kubernetes/ssl/kubernetes-key.pem \
--client-ca-file={{ pillar['rbd-path'] }}/kubernetes/ssl/ca.pem \
--service-account-key-file={{ pillar['rbd-path'] }}/kubernetes/ssl/ca-key.pem \
--logtostderr=true \
--service-cluster-ip-range=11.1.0.0/16"


exec /usr/bin/docker \
  run \
  --privileged \
  --restart=always \
  --net=host \
  --name kube-apiserver \
  --volume={{ pillar['rbd-path'] }}/kubernetes:{{ pillar['rbd-path'] }}/kubernetes \
  rainbond/kube-apiserver:v1.6.4 \
  $KUBE_APISERVER_OPTS