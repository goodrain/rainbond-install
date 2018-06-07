> Just fot tests

#### Local test

```bash
# Demo Centos 7.3
git clone https://github.com/goodrain/rainbond-install.git
cd rainbond-install/tests
bash -x ./install_salt.sh

# need update config (ip.) for pillar

# init system 

salt "*" state.sls init

# install storage default nfs
salt "*" state.sls storage

# install docker
salt "*" state.sls docker

# install etcd
salt "*" state.sls etcd



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
或者
./scripts/compute.sh init single compute01 172.16.0.191 /root/.ssh/id_rsa ssh

./scripts/compute.sh install
```