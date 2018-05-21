#!/bin/bash
#======================================================================================================================
#
#          FILE: download_resource.sh
#
#   DESCRIPTION: download rbd-pkgs and rbd-images
#
#          BUGS: https://github.com/goodrain/rainbond-install/issues
#
#     COPYRIGHT: (c) 2018 by the Goodrain Delivery Team.
#
#       LICENSE: Apache 2.0
#       CREATED: 05/15/2018 16:49:37 AM
#======================================================================================================================
[[ $DEBUG ]] && set -x 
. scripts/common.sh
trap 'exit' SIGINT SIGHUP
#================================Download rbd-pkgs=====================================================================

#---  FUNCTION  -------------------------------------------------------------------------------------------------------
#          NAME:  Prepare_env
#   DESCRIPTION:  make repos for docker salt glusterfs and others .
#----------------------------------------------------------------------------------------------------------------------
Prepare_env(){
    cat > /etc/yum.repos.d/docker-repo.repo << EOF
[docker-repo]
gpgcheck=1
gpgkey=http://repo.goodrain.com/gpg/RPM-GPG-KEY-CentOS-goodrain
enabled=1
baseurl=http://repo.goodrain.com/centos/\$releasever/3.5/\$basearch
name=Goodrain CentOS-\$releasever - for x86_64
EOF
    cat > /etc/yum.repos.d/saltstack.repo << EOF
[saltstack-repo]
name=SaltStack repo for Red Hat Enterprise Linux \$releasever
baseurl=https://repo.saltstack.com/yum/redhat/\$releasever/\$basearch/latest
enabled=1
gpgcheck=1
gpgkey=https://repo.saltstack.com/yum/redhat/\$releasever/\$basearch/latest/SALTSTACK-GPG-KEY.pub
       https://repo.saltstack.com/yum/redhat/\$releasever/\$basearch/latest/base/RPM-GPG-KEY-CentOS-7
EOF
    yum install centos-release-gluster -y 2>&1>/dev/null
    yum makecache 2>&1>/dev/null
}

#---  FUNCTION  -------------------------------------------------------------------------------------------------------
#          NAME:  Download_Pkgs
#   DESCRIPTION:  Download packages into a designation directory.
#----------------------------------------------------------------------------------------------------------------------
Download_Pkgs(){ 
    for Rbd_pkgs in $( ./scripts/yq r rainbond.sls rbd-pkgs.manage | awk '{print $2}')
      do
        ${INSTALL_BIN} install ${Rbd_pkgs} --downloadonly --downloaddir=$PWD/install/pkgs 2>&1>/dev/null
      done
}
#---  FUNCTION  -------------------------------------------------------------------------------------------------------
#          NAME:  Create_Repo
#   DESCRIPTION:  make repodata for local repo.
#----------------------------------------------------------------------------------------------------------------------
Create_Repo(){
    if [ ! $(which  createrepo 2>/dev/null) ];then
      yum install createrepo -y 2>&1>/dev/null && \
      createrepo --update  -pdo $PWD/install/pkgs $PWD/install/pkgs 2>&1>/dev/null
    else
      createrepo --update  -pdo $PWD/install/pkgs $PWD/install/pkgs 2>&1>/dev/null
    fi
}

#================================Download docker images====================================================================

#---  FUNCTION  -------------------------------------------------------------------------------------------------------
#          NAME:  Download_Image
#   DESCRIPTION:  Download images for docker we need.
#----------------------------------------------------------------------------------------------------------------------
Download_Image(){
#list every image we need
    [ $( systemctl is-active docker ) != "active" ] && systemctl start docker && systemctl enable docker >/dev/null
    rbd_moudles=(rbd-api rbd-dns rbd-registry rbd-repo rbd-worker rbd-eventlog rbd-entrance rbd-chaos rbd-lb rbd-mq rbd-webcli rbd-app-ui prometheus)
    database=(mysql)
    etcd=(server)
    kubernetes=(cfssl kubecfg api static manager schedule)
    network=(calico)
    proxy=(plugins runner adapter builder)
    for Moudles in ${rbd_moudles[@]} ${database[@]} ${etcd[@]} ${kubernetes[@]} ${network[@]} ${proxy[@]}
      do
        Img=$( ./scripts/yq r rainbond.sls *.$Moudles.image | grep -v null | awk '{print $2}')
        Ver=$( ./scripts/yq r rainbond.sls *.$Moudles.version | grep -v null | awk '{print $2}')
        Rbd_Img=$Img:$Ver
        Gzp_Name=$( echo $Img | sed 's/\//_/g' )_$Ver
        docker pull $Rbd_Img && docker save $Rbd_Img | gzip > $PWD/install/imgs/$Gzp_Name.gz
      done
#yq会将3.0处理为3，这会导致rainbond/pause-amd64:3.0无法正常拉取，故单独处理
    docker pull rainbond/pause-amd64:3.0 && docker save rainbond/pause-amd64:3.0 | gzip > $PWD/install/imgs/rainbond_pause-amd64_3.0.gz
}

#---  FUNCTION  -------------------------------------------------------------------------------------------------------
#          NAME:  Speed_Up
#   DESCRIPTION:  let images pull faster.
#----------------------------------------------------------------------------------------------------------------------
Speed_Up(){
    if [ ! -f /etc/docker/daemon.json ];then
    cat > /etc/docker/daemon.json << EOF
{
  "registry-mirrors": [
    "https://registry.docker-cn.com"
  ]
}
EOF
    fi
}

#---  FUNCTION  -------------------------------------------------------------------------------------------------------
#          NAME:  help_func
#   DESCRIPTION:  print help info.
#----------------------------------------------------------------------------------------------------------------------
help_func(){
    echo "help:"
    echo "pkg      --- download packages and make repo"
    echo "img      --- download docker images cmd "
    echo "help     --- get help info cmd "
    echo ""
}

#==================================Main=================================================================================
case "$1" in
  pkg)
    Echo_Info "begin to prepare the repos···"
    Prepare_env && Echo_Ok
    Echo_Info "begin to download the packages···"
    Download_Pkgs && Echo_Ok
    Echo_Info "begin to create the repodata···"
    Create_Repo && Echo_Ok
  ;;
  img)
    Echo_Info "begin to pull docker images···"
    Speed_Up && Download_Image && Echo_Ok
  ;;
  *)
    help_func
  ;;
esac
    
  
    
