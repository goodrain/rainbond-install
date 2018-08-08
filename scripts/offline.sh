#!/bin/bash

REPO_PATH=/opt/rainbond/install
PKG_PATH=/opt/rainbond/install/install/pkgs
IMG_PATH=/opt/rainbond/install/install/imgs

YAML_PATH=$REPO_PATH/rainbond.yaml.default


which yq >/dev/null 2>&1 || (
    curl https://pkg.rainbond.com/releases/common/yq -o /usr/local/bin/yq
    chmod +x /usr/local/bin/yq
)

[ -d "$REPO_PATH" ] || mkdir -p $REPO_PATH

init(){
    which git > /dev/null 2>&1 || (
        yum install -y git
    )
    git clone --depth 1 -b v3.7 https://github.com/goodrain/rainbond-install.git $REPO_PATH
    [ -d "$PKG_PATH" ] || mkdir -p $PKG_PATH/{debian,centos}
    [ -d "$IMG_PATH" ] || mkdir -p $IMG_PATH
    curl https://pkg.rainbond.com/releases/common/v3.7.0rc/grctl -o $REPO_PATH/grctl
    #cp $REPO_PATH/install/rainbond.yaml.default $REPO_PATH/rainbond.yaml.default
    chmod +x $REPO_PATH/grctl
}

debian_pkg(){
    echo "download debian offline package"
    docker run --rm -v ${REPO_PATH}/rainbond.yaml.default:${REPO_PATH}/rainbond.yaml.default -v ${PKG_PATH}/debian:/var/cache/apt/archives rainbond/pkg-download:debian-95
}

ubuntu_pkg(){
    echo "download ubuntu offline package"
    docker run --rm -v ${REPO_PATH}/rainbond.yaml.default:${REPO_PATH}/rainbond.yaml.default -v ${PKG_PATH}/ubuntu:/var/cache/apt/archives/ rainbond/pkg-download:ubuntu-1604
}

centos_pkg(){
    echo "download centos offline package"
    docker run --rm -v ${REPO_PATH}/rainbond.yaml.default:${REPO_PATH}/rainbond.yaml.default -v ${PKG_PATH}/centos:${PKG_PATH}/centos rainbond/pkg-download:centos-1708
}

download_img(){
    which docker > /dev/null 2>&1 || (
        curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun
        cat > /etc/docker/daemon.json <<EOF
{
  "registry-mirrors": ["https://registry.docker-cn.com"]
}        
EOF
    systemctl restart docker
    )

    rbd_plugins=(mysql rbd-api rbd-dns rbd-registry rbd-repo rbd-worker rbd-eventlog rbd-entrance rbd-chaos rbd-lb rbd-mq rbd-webcli rbd-app-ui rbd-monitor rbd-grafana)
    rbd_runtimes=(tcm mesh runner adapter builder pause rbd-cni k8s-cni)
    k8s=(cfssl kubecfg api static manager schedule server calico)
    for Moudles in ${rbd_plugins[@]} ${rbd_runtimes[@]} ${k8s[@]}
    do
        Img=$( yq r $YAML_PATH *.$Moudles.image | grep -v null | awk '{print $2}')
        if [ "$Img" == "pause-amd64" ];then
            Ver=3.0
        else
            Ver=$( yq r $YAML_PATH *.$Moudles.version | grep -v null | awk '{print $2}')
        fi
        if [  -z "$Img" -o -z "$Ver" ];then
            echo "not found $Moudles, skip..."
            continue
        fi
        Pub_Img=rainbond/$Img:$Ver
        if [ "$Img" == "builder" ];then
            Pri_Img=goodrain.me/$Img
        elif [ "$Img" == "mesh" ];then
            Pri_Img=goodrain.me/$Img:mesh_plugin    
        else
            Pri_Img=goodrain.me/$Img:$Ver
        fi

        #echo "$Moudles $Img $Ver $Pub_Img"
        echo "docker pull $Pub_Img"
        docker pull $Pub_Img >/dev/null 2>&1
        docker tag $Pub_Img $Pri_Img >/dev/null 2>&1
        echo "docker save $Pri_Img"
        docker save $Pri_Img | gzip > $IMG_PATH/goodrainme_${Img}_${Ver}.gz
    done
}

offline_tgz(){
    tar zcvf install.v3.7.$(date +%F).tgz /opt/rainbond/install
}

case $1 in
    init)
        init
    ;;
    ubuntu)
        ubuntu_pkg
    ;;
    debian)
        debian_pkg
    ;;
    centos)
        centos_pkg
    ;;
    image)
        download_img
    ;;
    tgz)
        offline_tgz
    ;;
    *)
        init
        download_img
        ubuntu_pkg
        debian_pkg
        centos_pkg
        offline_tgz
    ;;
esac