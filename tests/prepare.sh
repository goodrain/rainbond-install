#!/bin/bash

DOWNLOAD_URL=https://dl.repo.goodrain.com/repo

REPO_VER=3.5
PKG=ctl

prepare(){
    curl -L ${DOWNLOAD_URL}/${PKG}/${REPO_VER}/${PKG}.tgz -o /tmp/${PKG}.tgz
    tar xf /tmp/${PKG}.tgz -C /usr/local/bin --strip-components=1
    chmod a+x /usr/local/bin/*

    mkdir -p /grdata
}

install_salt(){
   hostname manage01
   echo "manage01" > /etc/hostname
   curl -L ${DOWNLOAD_URL}/bootstrap-salt.sh -o /tmp/install_salt.sh
   chmod +x /tmp/install_salt.sh
   bash /tmp/install_salt.sh
   # 172.30.42.1 docker0
   # 10.0.2.15 vbox nat 
   local_ip=$(ip ad | grep 'inet ' | egrep ' 10.|172.|192.168' | awk '{print $2}' | cut -d '/' -f 1 | grep -vE '(172.30.42.1|10.0.2.15)')
   cat > /etc/salt/master.d/master.conf <<EOF
interface: $local_ip
open_mode: True
auto_accept: True
EOF
    cat > /etc/salt/minion.d/minion.conf <<EOF
master: $local_ip
id: $(hostname -s)
EOF
  systemctl enable salt-master
  systemctl enable salt-minion
  systemctl start salt-master
  systemctl start salt-minion
  salt "*" test.ping
}

case $1 in
    *)
    prepare
    install_salt
    ;;
esac