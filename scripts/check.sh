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

# Name   : Get_Hostname
# Args   : hostname
# Return : 0|!0
function Get_Hostname(){
    hostname=$(hostname)
    Echo_Info "Your hostname is $hostname"
    if [ "$hostname" != "$DEFAULT_HOSTNAME" ];then
        hostname manage01
        echo $DEFAULT_HOSTNAME > /etc/hostname
        echo $DEFAULT_HOSTNAME >> /etc/hosts
        Echo_Info "Hostname has changed to the default $DEFAULT_HOSTNAME"
    fi
    echo "hostname: $DEFAULT_HOSTNAME" >> install/pillar/system_info.sls
}


# Name   : Get_Rainbond_Install_Path
# Args   : config_path、config_path_again、install_path
# Return : 0|!0
function Get_Rainbond_Install_Path(){

    read -p $'\t\e[32mDo you need assign a installation path (Default:/opt/rainbond) \e[0m (y/n) ' config_path
    if [ "$config_path" == "Y" -o "$config_path" == "y" ];then
    read -p $'\t\e[32mInput a installation path\e[0m (y/n) ' install_path
    # 如果用户未指定，使用默认
      if [ -z $install_path ];then
          read -p $'\t\e[32mYou never assign a installation path ,use default?\e[0m (y/n)' config_path_again
          if [ "$config_path" == "Y" -o "$config_path" == "y" ];then
            install_path=$DEFAULT_INSTALL_PATH
            Echo_Info "Use default path:$DEFAULT_INSTALL_PATH"
          else
            exit 1
          fi
      fi
      Echo_Info "What you assign path is $install_path"
    else
      install_path=$DEFAULT_INSTALL_PATH
      Echo_Info "Use default path:$DEFAULT_INSTALL_PATH"
    fi
    echo "install-dir: $install_path" >> install/pillar/system_info.sls
}

# Name   : Install_Salt
# Args   : Null
# Return : 0|!0
function Install_Salt(){
  ./scripts/bootstrap-salt.sh  -M -X -R $SALT_REPO  $SALT_VER 2>&1 > ${LOG_DIR}/${SALT_LOG}

 # echo interface: xx >> /etc/salt/master
 # echo master: xx >> /etc/salt/minion
}


# Name   : Check_System_Version
# Args   : sys_name、sys_version
# Return : 0|!0
function Check_System_Version(){
    sys_name=$(salt '*' grains.get os | tail -n 1)
    sys_version=$(salt '*' grains.get osrelease | tail -n 1)
      [[ $sys_name != *CentOS* ]]\
    &&[[ $sys_name != *Ubuntu* ]]\
    &&[[ $sys_name != *Debian* ]]\
    &&[[ $sys_version != *7* ]]\
    &&[[ $sys_version != *8* ]]\
    &&[[ $sys_version != *9* ]]\
    &&[[ $sys_version != *16.04* ]]\
    &&Echo_Info "$sys_name$sys_version is not supported temporarily"\
    ||Echo_Info "Your system is $sys_name$sys_version"
}

# Name   : Get_Net_Info
# Args   :
# Return : 0|!0
function Get_Net_Info(){

}

# Name   : Get_Hardware_Info
# Args   : cpu_num、memory_size
# Return : 0|!0
function Get_Hardware_Info(){
    cpu_num=$(salt '*' grains.get num_cpus | tail -n 1)
    memory_size=$()
    
}

# Name   : Download_package
# Args   :
# Return : 0|!0
function Download_package(){

}

# Name   : Write_Config
# Args   :
# Return : 0|!0
function Write_Config(){

}

Echo_Info "Checking internet connect ..."
Check_Internet $RAINBOND_HOMEPAGE && Echo_Ok || Echo_Error

Echo_Info "Checking hostname or reconfig ..."
Get_Hostname && Echo_Ok || Echo_Error

Echo_Info "Configing installation path ..."
Get_Rainbond_Install_Path  && Echo_Ok || Echo_Error

Echo_Info "Installing salt ..."
Install_Salt && Echo_Ok || Echo_Error

Echo_Info "Checking system version ..."
Check_System_Version && Echo_Ok || Echo_Error

#ipaddr(inet pub) type .mark in .sls
Echo_Info "Getting net information ..."
Get_Net_Info && Echo_Ok || Echo_Error

# disk cpu memory
Echo_Info "Getting Hardware information ..."
Get_Hardware_Info && Echo_Ok || Echo_Error 

Echo_Info "Downloading Components ..."
Download_package && Echo_Ok || Echo_Error

Echo_Info "Writing configuration ..."
Write_Config && Echo_Ok || Echo_Error