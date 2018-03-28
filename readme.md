## Description

A collection of Salt states used to provision an application-centric platform [Rainbond](https://github.com/goodrain/rainbond).

Support for:

- Rainbond Manage node - single node with Mysql database
- Rainbond Compute node - it is not automatically added to Rainbond environment
- Rainbond environment support - only support Kubernetes
- Docker registry - automatically provisioned on Manage start
- Support for different provision

Plugins Version:

- System OS:
    - Debian 9
    - Ubuntu 16.04
    - Centos 7.x (Centos 7.3)
- Kubernetes v1.6.4
- Docker v1.12.6
- Calico v2.4.1
- Etcd v3.2.13
- Rainbond Core Plugins v3.5
- Salt v2017.7.4


## Usage

#### Configuration options

#### Local test

```bash
# Demo Centos 7.3
git clone https://github.com/goodrain/rainbond-install.git
cd rainbond-install
bash -x tests/prepare.sh

cd /srv

ln -s /root/rainbond-install/install/salt .
ln -s /root/rainbond-install/install/pillar .

# need update config (ip.) for pillar

# init system 

salt "*" state.sls init

# install docker
salt "*" state.sls docker

# install etcd
salt "*" state.sls etcd

# install storage default nfs
salt "*" state.sls storage

# install network default Calico
salt "*" state.sls network

# install Kubernetes Manage node 
salt "*" state.sls kubernetes.server

# install Kubernetes Node
salt "*" state.sls kubernetes.node
```