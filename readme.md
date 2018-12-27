[![Docs](https://img.shields.io/badge/docs-v3.7.2-brightgreen.svg)](https://www.rainbond.com/docs/stable/getting-started/installation-guide.html)[![Build Status](https://travis-ci.org/goodrain/rainbond-install.svg?branch=dev)](https://travis-ci.org/goodrain/rainbond-install)

## Status(Abandoned)
Install Rainbond that version after 5.0.0, Please reference https://github.com/goodrain/rainbond-ansible

## Description

A collection of Salt states used to provision an application-centric platform [Rainbond](https://github.com/goodrain/rainbond).

Support for:

- Rainbond Manage node - single node with Mysql database
- Rainbond Compute node - it is not automatically added to Rainbond environment
- Rainbond environment support - support Kubernetes
- Docker registry - automatically provisioned on Manage start
- Support for different provision

Plugins Version:

- [Distribution](https://github.com/goodrain/rainbond-install/wiki/Select-Distribution)
- [Kubernetes v1.6.4](https://github.com/goodrain/kubernetes)
- [Docker v1.12.6](https://github.com/goodrain/moby)
- Calico v2.4.1
- Etcd v3.2.13
- [Rainbond Core Plugins v3.7.2](https://github.com/goodrain/rainbond)
- [Rainbond UI v3.7.2](https://github.com/goodrain/rainbond-ui)
- Salt v2018.3.2

## Operations Guide

### Prerequisites

- [Distribution-recommendation](https://github.com/goodrain/rainbond-install/wiki/Select-Distribution)
- [Custom-configuration](https://github.com/goodrain/rainbond-install/wiki/%E8%87%AA%E5%AE%9A%E4%B9%89%E9%85%8D%E7%BD%AE(Custom-configuration))
- [Software-and-Hardware-Requirements](https://github.com/goodrain/rainbond-install/wiki/Software-and-Hardware-Requirements)

### Install

- Quick start

```Bash
# Stable v3.7.2(v3.7)

git clone --depth 1 -b v3.7 https://github.com/goodrain/rainbond-install.git /opt/rainbond/install
cd /opt/rainbond/install
./setup.sh

or

grctl init 

# previous v3.6.1

git clone --depth 1 -b v3.6 https://github.com/goodrain/rainbond-install.git
cd rainbond-install
./setup.sh

# previous v3.5.2
git clone --depth 1 -b v3.5 https://github.com/goodrain/rainbond-install.git
cd rainbond-install
./setup.sh
```

### Documents

You can find all the documentation in the [troubleshooting install](https://www.rainbond.com/docs/stable/operation-manual/trouble-shooting/install-issue.html)/[Docs](https://www.rainbond.com/docs/stable/).

## License

This project is licensed under the Apache License, Version 2.0. See [LICENSE](https://github.com/goodrain/rainbond-install/blob/master/LICENSE) for the full license text.
