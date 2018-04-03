#!/bin/bash
#======================================================================================================================
#
#          FILE: install.sh
#
#   DESCRIPTION: Install
#
#          BUGS: https://github.com/goodrain/rainbond-install/issues
#
#     COPYRIGHT: (c) 2018 by the Goodrain Delivery Team.
#
#       LICENSE: Apache 2.0
#       CREATED: 03/30/2018 10:49:37 AM
#======================================================================================================================

REPO_URL="https://github.com/goodrain/rainbond-install.git"

which_cmd() {
    which "${1}" 2>/dev/null || \
        command -v "${1}" 2>/dev/null
}

check_cmd() {
    which_cmd "${1}" >/dev/null 2>&1 && return 0
    return 1
}

APT="$(which_cmd apt)"
YUM="$(which_cmd yum)"

pkg(){
    if [ ! -z "$YUM" ];then
        yum makecache
        yum install -y ntpdate tar git wget perl tree nload curl telnet bind-utils htop dstat net-tools  lsof iproute rsync lvm2 bash-completion 
        echo "update localtime"
        ntpdate 0.cn.pool.ntp.org
    else
        apt update
        apt install -y git ntpdate wget curl tar lsof htop nload rsync net-tools telnet iproute2 lvm2 tree systemd
        ntpdate 0.cn.pool.ntp.org
    fi
}

run(){
    pkg
    [ -d "$PWD/rainbond-install" ] && rm -rf $PWD/rainbond-install
    git clone ${REPO_URL}
    cd rainbond-install
    if [[ $1 == "help" ]];then
        ./setup.sh
        echo "cd $PWD/rainbond-install;  ./setup.sh <args>"
    elif [[ $1 == "dev" ]];then
        ./setup.sh dev
    else
        ./setup.sh install
    fi
}
case $1 in
    dev)
        run dev
    ;;
    help)
        run help
    ;;
    * )
        run
    ;;
esac