# rainbond global config
# use ./scripts/yq maintain
# example:
# read:           ./scripts/yq r t.yml etcd.server.members[0].name
# write/update:   ./scripts/yq w t.yml etcd.server.members[0].name compute01
# more information: http://mikefarah.github.io/yq/
rbd-version: 3.6
rbd-path: /opt/rainbond
inet-ip: 
public-ip: 
# master-hostname: 
hostname: manage01
domain: xxx.goodrain.org
install-script-path: 
rbd-tag: rainbond
dns: 114.114.114.114
rbd-images:
  k8s-cni-image: rainbond/cni:k8s_v3.6
  rbd-cni-image: rainbond/cni:rbd_v3.6
  calico-node: rainbond/calico-node:v2.4.1
  rbd-db: rainbond/rbd-db:3.6
  etcd: rainbond/etcd:v3.2.13
  cfssl_image: rainbond/cfssl:dev
  kubecfg_image: rainbond/kubecfg:dev
  api_image: rainbond/kube-apiserver:v1.6.4
  manager: rainbond/kube-controller-manager:v1.6.4
  schedule: rainbond/kube-scheduler:v1.6.4

rbd-pkgs:
  manage:
    - salt-master
    - salt-minion
  compute:
    - salt-minion

k8s-cni-image: rainbond/cni:k8s_v3.6
rbd-cni-image: rainbond/cni:rbd_v3.6

# rbd-db
database:
  mysql:
    image: rainbond/rbd-db:3.5
    host: 172.16.0.210
    port: 3306
    user: write
    pass: aab8a509

# etcd
etcd:
  server:
    image: rainbond/etcd:v3.2.13
    enabled: true
    bind:
      host: 172.16.0.210
    token: 9fd3739a-6b7c-4fa8-804c-862c129addf5
    members:
    - host: 172.16.0.210
      name: manage01
      port: 2379
  proxy:
    image: rainbond/etcd:v3.2.13
    enabled: true

# kubernetes
kubernetes:
  server:
    cfssl_image: rainbond/cfssl:dev
    kubecfg_image: rainbond/kubecfg:dev
    api_image: rainbond/kube-apiserver:v1.6.4
    manager: rainbond/kube-controller-manager:v1.6.4
    schedule: rainbond/kube-scheduler:v1.6.4

# network
network:
  calico:
    image: rainbond/calico-node:v2.4.1
    enabled: true
    bind: 172.16.0.210
    net: 10.0.0.0/16

# plugins
plugins:
  core:
    api:
      image: rainbond/rbd-api