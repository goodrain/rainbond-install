#!/bin/bash

wget https://pkg.rainbond.com/releases/common/v3.7.0rc/imgs/install.offline.v3.7rc.tgz -O ./install.offline.v3.7rc.imgs.tgz

wget https://pkg.rainbond.com/releases/common/v3.7.0rc/pkgs/install.offline.v3.7rc.tgz -O ./install.offline.v3.7rc.pkgs.tgz

mkdir -p /opt/rainbond/install
git clone --depth 1 -b v3.7 https://github.com/goodrain/rainbond-install.git /opt/rainbond/install
rm -rf /opt/rainbond/install/.git
wget https://pkg.rainbond.com/releases/common/v3.7.0rc/grctl -O /opt/rainbond/install/grctl


tar zcvf install.offline.v3.7rc.salt.tgz /opt/rainbond/install

tar xf install.offline.v3.7rc.imgs.tgz -C /
tar xf install.offline.v3.7rc.pkgs.tgz -C /

 /opt/rainbond/install/grctl init --install-type offline