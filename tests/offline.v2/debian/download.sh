#!/bin/bash

if [ "$1" == "bash" ];then
    exec /bin/bash
else
    #YAML_PATH=/opt/rainbond/install/rainbond.yaml.default
    PKG_PATH=/opt/rainbond/install/install/pkgs
    apt update
    echo "download debian/ubuntu offline package"
    #dpkg=$(yq r $YAML_PATH rbd-pkgs.debian | awk '{print $2}')
    #common_pkg=$(yq r $YAML_PATH rbd-pkgs.common | awk '{print $2}')
        dpkg=(nfs-kernel-server nfs-common dnsutils python-pip python-apt apt-transport-https uuid-runtime iproute2 systemd)
    common_pkg=(gr-docker-engine tar ntpdate wget curl tree lsof htop nload net-tools telnet rsync git dstat salt-master salt-minion salt-ssh iotop lvm2 ntpdate pwgen)
    for pkg in ${dpkg[@]} ${common_pkg[@]}
    do
        apt install ${pkg} -d -y  >/dev/null 2>&1
        #cp -a /var/cache/apt/archives/$pkg* $PKG_PATH/debian/
        echo "download debian $pkg ok"
    done
    cp -a /var/cache/apt/archives/*.deb /tmp/
    apt-get install reprepro -y
    mkdir -p /opt/rainbond/install/install/pkgs/debian/9/conf/
    touch /opt/rainbond/install/install/pkgs/debian/9/conf/{distributions,options,override.local}
    cat > /opt/rainbond/install/install/pkgs/debian/9/conf/distributions <<EOF
Origin: rainbond
Label: rainbond
Codename: local
Architectures: amd64
Components: main pre
Description: rainbond debian package local repo 
EOF
    cat > /opt/rainbond/install/install/pkgs/debian/9/conf/options <<EOF
verbose
basedir /opt/rainbond/install/install/pkgs/debian/9/
EOF
    for deb in /tmp/*
    do
        echo $deb | grep ".deb" && (
            reprepro -Vb /opt/rainbond/install/install/pkgs/debian/9  -C main -P optional -S net  includedeb local $deb
        )
    done
fi