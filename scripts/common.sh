#!/bin/bash

[[ $DEBUG ]] && set -x

# set env
SALT_VER="stable 2017.7.4"
SALT_REPO="mirrors.ustc.edu.cn/salt"
RAINBOND_HOMEPAGE="https://www.rainbond.com"
DEFAULT_INSTALL_PATH="/opt/rainbond"
STORAGE_PATH="/grdata"
LOG_DIR="logs"
CHECK_LOG="check.log"
SALT_LOG="install_salt.log"
DEFAULT_HOSTNAME="manage01"
OSS_DOMAIN="https://dl.repo.goodrain.com"
OSS_PATH="repo/ctl/3.5"
DATE="$(date +"%Y-%m-%d %H:%M:%S")"
INFO_FILE="./install/pillar/system_info.sls"
CPU_NUM=$(grep "processor" /proc/cpuinfo | wc -l )
CPU_LIMIT=2
MEM_SIZE=$(free -h | grep Mem | awk '{print $2}' | cut -d 'G' -f1 | awk -F '.' '{print $1}')
MEM_LIMIT=4
DEFAULT_LOCAL_IP=$(ip ad | grep 'inet ' | egrep ' 10.|172.|192.168' | awk '{print $2}' | cut -d '/' -f 1 | grep -v '172.30.42.1' | head -1)



#---  FUNCTION  -------------------------------------------------------------------------------------------------------
#          NAME:  __detect_color_support
#   DESCRIPTION:  Try to detect color support.
#----------------------------------------------------------------------------------------------------------------------
COLORS=${BS_COLORS:-$(tput colors 2>/dev/null || echo 0)}
Detect_Color_Support() {
    if [ $? -eq 0 ] && [ "$COLORS" -gt 2 ]; then
        RC="\033[1;31m"
        GC="\033[1;32m"
        BC="\033[1;34m"
        YC="\033[1;33m"
        EC="\033[0m"
    else
        RC=""
        GC=""
        BC=""
        YC=""
        EC=""
    fi
}
Detect_Color_Support


#---  FUNCTION  -------------------------------------------------------------------------------------------------------
#          NAME:  Echo_Error
#   DESCRIPTION:  Echo errors to stderr.
#----------------------------------------------------------------------------------------------------------------------
Echo_Error() {
    printf "${RC} ERROR!!!${EC}\n" 1>&2;
}

#---  FUNCTION  -------------------------------------------------------------------------------------------------------
#          NAME:  Echo_Info
#   DESCRIPTION:  Echo information to stdout.
#----------------------------------------------------------------------------------------------------------------------
Echo_Info() {
    printf "\t%s" "$@";
}

#---  FUNCTION  -------------------------------------------------------------------------------------------------------
#          NAME:  Echo_Ok
#   DESCRIPTION:  Echo debug information to stdout.
#----------------------------------------------------------------------------------------------------------------------
Echo_Ok() {
   printf "${GC} OK${EC}\n";
}
