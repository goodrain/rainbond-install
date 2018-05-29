#!/bin/bash
#======================================================================================================================
#
#          FILE: prepare_install.sh
#
#   DESCRIPTION: before install rainbond offline. you should run this script.
#
#          BUGS: https://github.com/goodrain/rainbond-install/issues
#
#     COPYRIGHT: (c) 2018 by the Goodrain Delivery Team.
#
#       LICENSE: Apache 2.0
#       CREATED: 05/15/2018 16:49:37 AM
#======================================================================================================================
[[ $DEBUG ]] && set -x
. scripts/common.sh offline
trap 'exit' SIGINT SIGHUP
#================================write a local repo file================================================================

Local_Repo(){
    cat > /etc/yum.repos.d/rainbond_local.repo << EOF
[rainbond_local]
name=rainbond_offline_install_repo
baseurl=file:///root/rainbond-install/install/pkgs
gpgcheck=0
enabled=1
EOF
    yum makecache -q
}

Salt_Install(){
    ${INSTALL_BIN} install -y -q salt-master salt-minion && systemctl start salt* && systemctl status salt*
}

#================================start gr-docker daemon=================================================================

Docker_Run(){
    ${INSTALL_BIN} install -y -q gr-docker-engine
    sed -i 's/\/etc\/goodrain/\/opt\/rainbond/g' /usr/lib/systemd/system/docker.service
    mkdir -p /opt/rainbond/envs
    cat > /opt/rainbond/envs/docker.sh << EOF
DOCKER_OPTS="-H 0.0.0.0:2376 -H \
unix:///var/run/docker.sock \
--bip=172.30.42.1/16 \
--insecure-registry goodrain.me \
--storage-driver=devicemapper \
--userland-proxy=false"
EOF
    systemctl daemon-reload && systemctl start docker
    [ ! $( systemctl is-active docker ) ] \
    && Echo_Info "docker daemon is not running , please check it!" \
    && Echo_Error || return 0
}

#================================Load docker images======================================================================

Load_Image(){
    for Tar in $( ls -l $PWD/install/imgs/*.gz | awk '{print $9}' )
      do 
        docker load -qi $Tar
      done
}

help_func(){
    echo "help:"
    echo "repo    --- write a local repo file for rainbond cmd "
    echo "docker     --- start rainbond docker daemon cmd "
    echo "help     --- get help info cmd "
    echo ""
}
#================================Main=====================================================================================

#case $1 in 
#help)
#  help_func
#;;
#docker)
#  Docker_Run && Echo_Ok
#;;
#*)
#  Local_Repo && Docker_Run && Load_Image && Echo_Ok
#;;
#esac
Local_Repo && Docker_Run && Load_Image && Echo_Ok
