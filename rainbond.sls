# rainbond global config
# use ./scripts/yq maintain
# example:
# read:           ./scripts/yq r t.yml etcd.server.members[0].name
# write/update:   ./scripts/yq w t.yml etcd.server.members[0].name compute01
# more information: http://mikefarah.github.io/yq/
rbd-version: 3.5
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
  allcli: rainbond/static:allcli_v3.5   
  calico-node: rainbond/calico-node:v2.4.1 
  rbd-db: rainbond/rbd-db:{{ pillar["rbd-version"] }}
  etcd: rainbond/etcd:v3.2.13
  cfssl_image: rainbond/cfssl:dev
  kubecfg_image: rainbond/kubecfg:dev
  api_image: rainbond/kube-apiserver:v1.6.4
  manager: rainbond/kube-controller-manager:v1.6.4
  scheduler: rainbond/kube-scheduler:v1.6.4
  rbd-dns: rainbond/rbd-dns:{{ pillar["rbd-version"] }}
  rbd-registry: rainbond/rbd-registry:2.3.1
  rbd-repo: rainbond/rbd-repo:{{ pillar["rbd-version"] }}
  rbd-worker: rainbond/rbd-worker:{{ pillar['rbd-version'] }}
  rbd-eventlog: rainbond/rbd-eventlog:{{ pillar['rbd-version'] }}
  rbd-entrance: rainbond/rbd-entrance:{{ pillar['rbd-version'] }}
  rbd-api: rainbond/rbd-api:{{ pillar['rbd-version'] }}
  rbd-chaos: rainbond/rbd-chaos:{{ pillar['rbd-version'] }}
  rbd-lb: rainbond/rbd-lb:3.5-new
  rbd-mq: rainbond/rbd-mq:{{ pillar['rbd-version'] }}
  rbd-webcli: rainbond/rbd-webcli:{{ pillar['rbd-version'] }}
  rbd-app-ui: rainbond/rbd-app-ui:{{ pillar['rbd-version'] }}
  promethes: rainbond/prometheus:v2.0.0   
  plugins: rainbond/plugins:tcm
  runner: rainbond/runner
  adapter: rainbond/adapter
  pause: rainbond/pause-amd64:3.0   
  builder: rainbond/builder

rbd-pkgs:
  manage:
    - gr-docker-engine
    - nfs-utils
    - nfs-kernel-server
    - nfs-common
    - glusterfs-server
    - tar
    - ntp
    - wget
    - curl
    - tree
    - lsof
    - htop
    - nload
    - net-tools
    - telnet
    - rsync
    - lvm2
    - git
    - salt-ssh
    - perl
    - bind-utils
    - dstat 
    - iproute
    - bash-completion
    - salt-master
    - salt-minion

# rbd-db
database:
  mysql:
    image: rainbond/rbd-db
    version: 3.5
    host: 172.16.0.210
    port: 3306
    user: write
    pass: aab8a509

# etcd
etcd:
  server:
    image: rainbond/etcd
    version: v3.2.13
    enabled: true
    bind:
      host: 172.16.0.210
    token: 9fd3739a-6b7c-4fa8-804c-862c129addf5
    members:
    - host: 172.16.0.210
      name: manage01
      port: 2379
  proxy:
    image: rainbond/etcd
    version: v3.2.13
    enabled: true

# kubernetes
kubernetes:
  cfssl:
    image: rainbond/cfssl
    version: dev
  kubecfg:
    image: rainbond/kubecfg
    version: dev
  static:
    image: rainbond/static
    version: allcli_v3.5
  api:
    image: rainbond/kube-apiserver
    version: v1.6.4
  manager:
    image: rainbond/kube-controller-manager
    version: v1.6.4
  schedule:
    image: rainbond/kube-scheduler
    version: v1.6.4

# network
network:
  calico:
    image: rainbond/calico-node
    version: v2.4.1
    enabled: true
    bind: 172.16.0.210
    net: 10.0.0.0/16

#proxy
proxy:
  runner:
    image: rainbond/runner
    version: latest
  plugins:
    image: rainbond/plugins
    version: tcm
  adapter:
    image: rainbond/adapter
    version: latest
  pause:
    image: rainbond/pause-amd64
    version: '3.0'
  builder:
    image: rainbond/builder
    version: latest

# plugins
rainbond-modules:
  rbd-api:
    image: rainbond/rbd-api
    version: '3.5'
  rbd-dns:       
    image: rainbond/rbd-dns
    version: '3.5'
  rbd-registry: 
    image: rainbond/rbd-registry
    version: '2.3.1'
  rbd-repo: 
    image: rainbond/rbd-repo
    version: '3.5'
  rbd-worker: 
    image: rainbond/rbd-worker
    version: '3.5'
  rbd-eventlog: 
    image: rainbond/rbd-eventlog
    version: '3.5'
  rbd-entrance: 
    image: rainbond/rbd-entrance
    version: '3.5'
  rbd-chaos: 
    image: rainbond/rbd-chaos
    version: '3.5'
  rbd-lb: 
    image: rainbond/rbd-lb
    version: '3.5'
  rbd-mq: 
    image: rainbond/rbd-mq
    version: '3.5'
  rbd-webcli: 
    image: rainbond/rbd-webcli
    version: '3.5'
  rbd-app-ui: 
    image: rainbond/rbd-app-ui
    version: '3.5'
  prometheus: 
    image: rainbond/prometheus
    version: 'v2.0.0'
    
