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

```
wget https://raw.githubusercontent.com/goodrain/rainbond-install/master/install.sh 
chmod +x install.sh 
./install.sh
```

