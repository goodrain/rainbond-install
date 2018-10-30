#!/bin/bash

if [ "$1" == "bash" ];then
    exec /bin/bash
else
    #YAML_PATH=/opt/rainbond/install/rainbond.yaml.default
    PKG_PATH=/opt/rainbond/install/install/pkgs
    #cpkg=$(yq r $YAML_PATH rbd-pkgs.centos | awk '{print $2}')
    cpkg=(nfs-utils portmap perl bind-utils iproute bash-completion createrepo centos-release-gluster glusterfs-server bridge-utils)
    #common_pkg=$(yq r $YAML_PATH rbd-pkgs.common | awk '{print $2}')
    common_pkg=(gr-docker-engine tar ntpdate wget curl tree lsof htop nload net-tools telnet rsync git dstat salt-master salt-minion salt-ssh iotop lvm2 ntpdate pwgen)
    for pkg in ${cpkg[@]} ${common_pkg[@]}
    do
        yum install ${pkg} --downloadonly --downloaddir=$PKG_PATH/centos/ >/dev/null 2>&1
        ls $PKG_PATH/centos/ | grep "$pkg" >/dev/null 2>&1
        if [ "$?" == 0 ];then
            echo "download centos $pkg ok"
        else
            echo "download centos $pkg failed"
        fi
    done
    yum install -y createrepo >/dev/null 2>&1
    createrepo /opt/rainbond/install/install/pkgs/centos/  >/dev/null 2>&1
fi