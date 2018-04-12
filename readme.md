[![Docs](https://img.shields.io/badge/docs-v3.5-brightgreen.svg)](https://www.rainbond.com/docs/stable/getting-started/pre-install.html)[![Build Status](https://travis-ci.org/goodrain/rainbond-install.svg?branch=master)](https://travis-ci.org/goodrain/rainbond-install)

## Description

A collection of Salt states used to provision an application-centric platform [Rainbond](https://github.com/goodrain/rainbond).

Support for:

- Rainbond Manage node - single node with Mysql database
- Rainbond Compute node - it is not automatically added to Rainbond environment
- Rainbond environment support - support Kubernetes
- Docker registry - automatically provisioned on Manage start
- Support for different provision

Plugins Version:

- System OS:
    - Debian 9
    - Ubuntu 16.04
    - Centos 7.x (Centos 7.3)
- [Kubernetes v1.6.4](https://github.com/goodrain/kubernetes)
- [Docker v1.12.6](https://github.com/goodrain/moby)
- Calico v2.4.1
- Etcd v3.2.13
- [Rainbond Core Plugins v3.5](https://github.com/goodrain/rainbond)
- [Rainbond UI v3.5](https://github.com/goodrain/rainbond-ui)
- Salt v2017.7.4


## Documentation

#### Install

- Quick start

```
# stable 
curl -k -L -o install.sh https://raw.githubusercontent.com/goodrain/rainbond-install/master/install.sh 
chmod +x install.sh 
./install.sh

# dev
curl -k -L -o install.sh https://raw.githubusercontent.com/goodrain/rainbond-install/dev/install.sh
chmod +x install.sh
./install.sh dev
```

You can find all the documentation in the [Wiki](https://github.com/goodrain/rainbond-install/wiki).

#### Usage

You can find all the documentation in the [Docs](https://www.rainbond.com/docs/stable/).

## License

This project is licensed under the Apache License, Version 2.0. See [LICENSE](https://github.com/goodrain/rainbond-install/blob/master/LICENSE) for the full license text.