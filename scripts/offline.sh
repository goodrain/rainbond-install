#!/bin/bash

PKG_PATH=/opt/rainbond/install/pkgs
IMG_PATH=/opt/rainbond/install/imgs

[ -d "$PKG_PATH" ] || mkdir -p $PKG_PATH/{debian,centos}
[ -d "$IMG_PATH" ] || mkdir -p $IMG_PATH 

debian_pkg(){
    echo "download debian/ubuntu offline package"
    for pkg in $( ./scripts/yq r rainbond.yaml.default rbd-pkgs.debian | awk '{print $2}')
    do
        apt install ${pkg} -d  2>&1>/dev/null
        cp -a /var/cache/apt/archives/$pkg* $PKG_PATH/debian/
        echo "download debian $pkg ok"
    done
}

centos_pkg(){
    echo "download centos offline package"
    for pkg in $( ./scripts/yq r rainbond.yaml.default rbd-pkgs.centos | awk '{print $2}')
    do
        yum install ${pkg} --downloadonly --downloaddir=$PKG_PATH/centos/ 2>&1>/dev/null
        echo "download centos $pkg ok"
    done
}

download_pkg(){
    if [ "$1" == "all" ];then
        centos_pkg
        debian_pkg
    elif [ "$1" == "debian" -o "$1" == "ubuntu" ];then
        debian_pkg
    else
        centos_pkg
    fi
}

download_img(){
    rbd_plugins=(rbd_api )
    rbd_runtimes=(runner)
    rbd_db=(mysql)
    network=(calico)
    etcd=(etcd)
    kubernetes=(cfssl)
    for Moudles in ${rbd_plugins[@]} ${rbd_runtimes[@]} ${rbd_db[@]} ${kubernetes[@]} ${network[@]} ${etcd[@]}
    do
        Img=$( ./scripts/yq r rainbond.yaml.default *.$Moudles.image | grep -v null | awk '{print $2}')
        Ver=$( ./scripts/yq r rainbond.yaml.default *.$Moudles.version | grep -v null | awk '{print $2}')
        Rbd_Img=$Img:$Ver
        Gzp_Name=$( echo $Img | sed 's/\//_/g' )_$Ver
        docker pull $Rbd_Img && docker save $Rbd_Img | gzip > $PWD/install/imgs/$Gzp_Name.gz
    done
}

offline_tgz(){

}

case $1 in
    *)
    download_pkg ${1:-all}
    download_img ${2:-3.7}
    offline_tgz
    ;;
esac