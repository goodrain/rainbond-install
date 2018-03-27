#!/bin/bash

DOWNLOAD_URL=https://dl.repo.goodrain.com/repo/ctl

REPO_VER=v3.5


prepare(){
    curl -L ${DOWNLOAD_URL}/{REPO_VER}/ctl.tgz -o /tmp/ctl.tgz
    tar xf /tmp/ctl.tgz -C /usr/local/bin --strip-components=1
    chmod a+x /usr/local/bin/*

    mkdir -p /grdata
}

case $1 in
    *)
    prepare
    ;;
esac