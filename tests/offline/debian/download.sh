#!/bin/bash

if [ "$1" == "bash" ];then
    exec /bin/bash
else
    YAML_PATH=/opt/rainbond/install/rainbond.yaml.default
    PKG_PATH=/opt/rainbond/install/install/pkgs
    apt update
    echo "download debian/ubuntu offline package"
    dpkg=$(yq r $YAML_PATH rbd-pkgs.debian | awk '{print $2}')
    common_pkg=$(yq r $YAML_PATH rbd-pkgs.common | awk '{print $2}')
    for pkg in ${dpkg[@]} ${common_pkg[@]}
    do
        apt install ${pkg} -d -y  >/dev/null 2>&1
        cp -a /var/cache/apt/archives/$pkg* $PKG_PATH/debian/
        echo "download debian $pkg ok"
    done
fi