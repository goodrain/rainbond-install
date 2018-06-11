#!/bin/bash
#======================================================================================================================
#
#          FILE: install_gr-docker.sh
#
#   DESCRIPTION: Install
#
#          BUGS: https://github.com/goodrain/rainbond-install/issues
#
#     COPYRIGHT: (c) 2018 by the Goodrain Delivery Team.
#
#       LICENSE: Apache 2.0
#       CREATED: 06/05/2018 12:26:15 PM
#======================================================================================================================
[[ $DEBUG ]] && set -x


config_repo(){
    cat > /etc/yum.repos.d/docker-repo.repo <<EOF
[docker-repo]
gpgcheck=1
gpgkey=http://repo.goodrain.com/gpg/RPM-GPG-KEY-CentOS-goodrain
enabled=1
baseurl=http://repo.goodrain.com/centos/$releasever/3.5/$basearch
name=Goodrain CentOS-$releasever - for x86_64
EOF
    yum makecache fast -q
    mkdir -p /opt/rainbond/envs
    cat > /opt/rainbond/envs/docker.sh <<EOF
DOCKER_OPTS="-H unix:///var/run/docker.sock --bip=172.30.42.1/16 --insecure-registry goodrain.me --storage-driver=devicemapper --storage-opt dm.fs=ext4 --userland-proxy=false"
EOF
}

install_docker(){
    yum install gr-docker-engine -y
    systemctl stop docker
    cat > /usr/lib/systemd/system/docker.service <<EOF
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network.target

[Service]
Type=notify
EnvironmentFile=/opt/rainbond/envs/docker.sh
ExecStart=/usr/bin/dockerd $DOCKER_OPTS
ExecReload=/bin/kill -s HUP $MAINPID
LimitNOFILE=1048576
LimitNPROC=1048576
LimitCORE=infinity
TimeoutStartSec=0
Delegate=yes
KillMode=process

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl start docker
}

case $1 in
    *)
    config_repo
    install_docker
    ;;
esac