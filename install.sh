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

[[ $DEBUG ]] && set -x

STABLE_VER="3.5.1"
PKG_URL="https://pkg.rainbond.com/releases"
STABLE_PKG="stable/v3.5.1.tar.gz"
[ -d "~/rainbond-install-$STABLE_VER" ] && rm -rf ~/rainbond-install-$STABLE_VER
       
curl -s -L -k  ${PKG_URL}/${STABLE_PKG} | tar xzm -C ~/
    
cd ~/rainbond-install-$STABLE_VER

./setup.sh install