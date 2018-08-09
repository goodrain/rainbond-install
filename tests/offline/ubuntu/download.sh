#!/bin/bash

if [ "$1"  == "bash" ];then
    exec /bin/bash
else
    YAML_PATH=/opt/rainbond/install/rainbond.yaml.default
    PKG_PATH=/opt/rainbond/install/install/pkgs
    apt update
    echo "download ubuntu offline package"
    dpkg=$(yq r $YAML_PATH rbd-pkgs.debian | awk '{print $2}')
    common_pkg=$(yq r $YAML_PATH rbd-pkgs.common | awk '{print $2}')
    for pkg in ${dpkg[@]} ${common_pkg[@]}
    do
        apt install ${pkg} -d -y  >/dev/null 2>&1
        #cp -a /var/cache/apt/archives/$pkg* $PKG_PATH/ubuntu/
        echo "download ubuntu $pkg ok"
    done
    apt-get install reprepro -y
    mkdir -p /opt/rainbond/install/install/pkgs/ubuntu/16/conf/
    touch /opt/rainbond/install/install/pkgs/ubuntu/16/conf/{distributions,options,override.local}
    cat > /opt/rainbond/install/install/pkgs/ubuntu/16/conf/distributions <<EOF
Origin: rainbond
Label: rainbond
Codename: local
Architectures: amd64
Components: main pre
Description: rainbond ubuntu package local repo 
EOF
    cat > /opt/rainbond/install/install/pkgs/ubuntu/16/conf/options <<EOF
verbose
basedir /opt/rainbond/install/install/pkgs/ubuntu/16/
EOF
    for deb in /var/cache/apt/archives/*
    do  
        echo $deb | grep ".deb" && (
            reprepro -Vb /opt/rainbond/install/install/pkgs/ubuntu/16  -C main -P optional -S net  includedeb local /var/cache/apt/archives/$deb 
        )
    done
fi