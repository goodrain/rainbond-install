> Just fot tests

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

#### local add compute node

```
cd rainbond-install
./scripts/compute.sh init single compute01 172.16.0.191 12345678
./scripts/compute.sh install
```