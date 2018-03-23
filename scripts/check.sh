#!/bin/bash

# Function : Check scripts for Rainbond install
# Args     : Null
# Author   : zhouyq (zhouyq@goodrain.com)
# Version  :
# 2018.03.22 first release

. scripts/common.sh


# Function : Check internet
# Args     : Check url
# Return   : (0|!0)
function Check_Internet(){
  check_url=$1
  curl -s --connect-timeout 3 $check_url -o /dev/null 2>/dev/null
}


# Name   : Install_Salt
# Args   : Null
# Return : 0|!0
function Install_Salt(){

  ./scripts/bootstrap-salt.sh  -M -X -R $SALT_REPO  $SALT_VER 2>&1 > ${LOG_DIR}/${SALT_LOG}

}

function Get_Rainbond_Install_Path(){

    read -p $'\t\e[32mPlease assign a installation path \e[0m (default:/opt/rainbond) ' install_path
    # 如果用户未指定，使用默认
    if [ -z $install_path ];then
        install_path=$DEFAULT_INSTALL_PATH
    fi
}


#Echo_Info "Checking internet connect ..."
#Check_Internet $RAINBOND_HOMEPAGE && Echo_Ok || Echo_Error

#Echo_Info "Installing salt ..."
#Install_Salt && Echo_Ok || Echo_Error

Get_Rainbond_Install_Path
