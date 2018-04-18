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

- [Distribution](https://github.com/goodrain/rainbond-install/wiki/Select-Distribution)
- [Kubernetes v1.6.4](https://github.com/goodrain/kubernetes)
- [Docker v1.12.6](https://github.com/goodrain/moby)
- Calico v2.4.1
- Etcd v3.2.13
- [Rainbond Core Plugins v3.5](https://github.com/goodrain/rainbond)
- [Rainbond UI v3.5](https://github.com/goodrain/rainbond-ui)
- Salt v2017.7.5

## Documentation

> Please read [Select-Distribution](https://github.com/goodrain/rainbond-install/wiki/Select-Distribution) before installation.


### Install

- Quick start

```Bash
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

### Add a compute node
Through a script Which is "add_node.sh" to add a compute node.

**Parameter**

```
-r <Role>,       Specify a node type <compute|manage> ,follow-up support management node.
-i <IP>,         The ip address what you Specified node
-p <Password>    The login password what you Specified node
```

**Usage**

```Bash
bash ./add_node.sh -r <compute|manage> -i <IP> -p <Password>
```

> **Such as:**
>
> ```Bash
> bash ./add_node.sh -r compute -i 192.168.1.1 -p 123456
> ```

### Documents

You can find all the documentation in the [Docs](https://www.rainbond.com/docs/stable/).

## License

This project is licensed under the Apache License, Version 2.0. See [LICENSE](https://github.com/goodrain/rainbond-install/blob/master/LICENSE) for the full license text.