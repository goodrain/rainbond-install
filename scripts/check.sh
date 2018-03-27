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
function Set_Hostname(){
    hostname manage01
    echo "manage01" > /etc/hostname
    Write_File check hostname 
    Write_File "hostname: $DEFAULT_HOSTNAME" $INFO_FILE
}


# Name   : Get_Rainbond_Install_Path
# Args   : config_path、config_path_again、install_path
# Return : 0|!0
function Get_Rainbond_Install_Path(){

  read -p $'\t\e[32mUse the default path:(/opt/rainbond) \e[0m (y=yes/c=custom) ' config_path

  if [ "$config_path" == "c" -o "$config_path" == "C" ];then
    read -p $'\t\e[32mInput a customize installation path\e[0m :' install_path
    # 如果用户未指定，使用默认
    if [ -z $install_path ];then
      install_path=$DEFAULT_INSTALL_PATH
      Echo_Info "Use default path:$DEFAULT_INSTALL_PATH"
    fi

  else
      install_path=$DEFAULT_INSTALL_PATH
      Echo_Info "Use default path:$DEFAULT_INSTALL_PATH"
  fi
  Write_File check rbd-path
  Write_File "rbd-path: $install_path" $INFO_FILE
}

# Name   : Install_Salt
# Args   : Null
# Return : 0|!0
function Install_Salt(){
  ./scripts/bootstrap-salt.sh  -M -X -R $SALT_REPO  $SALT_VER 2>&1 > ${LOG_DIR}/${SALT_LOG}
  # write salt config
cat > /etc/salt/master.d/pillar.conf << END
pillar_roots:
  base:
    - /_install_dir_/rainbond/install/pillar
END
cat > /etc/salt/master.d/salt.conf << END
file_roots:
  base:
    - /_install_dir_/rainbond/install/salt
END
    rbd-path=$(cat $INFO_FILE | grep rbd-path | awk '{print $2}')
    sed "s/_install_dir_/${rbd-path}/g" /etc/salt/master.d/pillar.conf
    sed "s/_install_dir_/${rbd-path}/g" /etc/salt/master.d/salt.conf
    echo "master: $hostname" > /etc/salt/minion.d/minion.conf 
    cp -rp ./install/pillar /${rbd-path}/rainbond/install/
    cp -rp ./install/ /${rbd-path}/rainbond/install/
    systemctl start salt-master
    systemctl start salt-minion
}


# Name   : Check_System_Version
# Args   : sys_name、sys_version
# Return : 0|!0
function Check_System_Version(){
    sys_name=$(cat /etc/os-release | grep NAME | head -1)
    sys_version=$(cat /etc/os-release | grep VERSION | head -1)
       [[ "$sys_version" =~ "7" ]] \
    || [[ "$sys_version" =~ "9" ]] \
    || [[ "$sys_version" =~ "16.04" ]] \
    || ( Write_File err_log "$sys_name$sys_version is not supported temporarily"
        exit 1)
}

# Name   : Get_Net_Info
# Args   : public_ips、public_ip、inet_ips、inet_ip、inet_size、
# Return : 0|!0
function Get_Net_Info(){
  Write_File check public-ip
  Write_File check inet-ip
  inet_ip=$(ip ad | grep 'inet ' | egrep ' 10.|172.|192.168' | awk '{print $2}' | cut -d '/' -f 1 | grep -v '172.30.42.1' | head -1)
  public_ip=$(ip ad | grep 'inet ' | grep -vE '( 10.|172.|192.168|127.)' | awk '{print $2}' | cut -d '/' -f 1 | head -1)
  net_cards=$(ls -1 /sys/class/net)
  if [ ! -z "$inet_ip" ];then
    for net_card in $net_cards
    do
      grep "inet_ip" /etc/sysconfig/network-scripts/ifcfg-$net_card \
      &&( Write_File check inet-ip && Write_File add "inet-ip: $inet_ip" $INFO_FILE ) \
      || Write_File err_log "There is no static ip config"
    done
  else
        Write_File err_log "There is no inet ip, exit ..."
    exit 1
  fi
  if [ ! -z "$public_ip" ];then
    Write_File add "public-ip: $public_ip" $INFO_FILE
  fi
}


# Name   : Get_Hardware_Info
# Args   : cpu_num、memory_size、disk
# Return : 0|!0
function Get_Hardware_Info(){

    cpu_num=$(cat /proc/cpuinfo | grep "processor" | wc -l )
    memory_size=$(free -h | grep Mem | awk '{print $2}' | cut -d 'G' -f1)
    if [ $cpu_num -lt 2 ];then
      Write_File err_log "There is $cpu_num cpus, you need more cpu, exit ..."
      exit 1
    fi

    if [ "$memory_size" < "2" ];then
      Write_File err_log "There is $memory_size memories, you need more memories, exit ..."
      exit 1
    elif [ "$memory_size" < "2" -a "$memory_size" < "4" ];then
      Write_File err_log "There is $memory_size memories, It is less than the standard quantity(4 memories), It may affect system performance"
    fi
}

# Name   : Download_package
# Args   :
# Return : 0|!0
function Download_package(){
    curl -s $OSS_DOMAIN/$OSS_PATH/ctl.md5 -o /tmp/ctl.md5
    curl -s $OSS_DOMAIN/$OSS_PATH/ctl.md5 -o /tmp/ctl.tgz
    md5sum -c /tmp/ctl.md5 > /dev/null 2>&1
      if [ $? -eq 0 ];then
        tar xf /tmp/ctl.tgz -C /usr/local/bin/ --strip-components=1
        return 0
      else

          Write_File err_log "The packge is broken, please contact staff to repair."
          exit 1
      fi
    rm /tmp/ctl.* -rf
}

# Name   : Write_Config
# Args   : db_name、db_pass
# Return : 0|!0
function Write_Config(){
    db_name=admin
    db_pass=$(echo $((RANDOM)) | base64 | md5sum | cut -b 1-8)
    Write_File check db-Name \
    && Write_File add "db-name : $db_name"  $INFO_FILE
    Write_File check db-pass \
    && Write_File add "db-pass : $db_pass"  $INFO_FILE
}


# Name   : Write_File
# Args   : none
# Return : none
function Write_File(){
  if [ "$1" == "add" ];then
    echo $2 >> $3
  elif [ "$1" == "err_log" ];then
    echo "$DATE :$2" >> ./logs/error.log
    Echo_Info "There seems to be some wrong here, you can check out the error logs in you installation dir (logs/error.log)"
  elif [ "$1" == "check" ];then
    key=$2
    grep $key $INFO_FILE
    if [ $? -eq 0 ];then
        sed -i -e "/$key/d" $INFO_FILE
    fi
  fi
}

#=============== main ==============

Echo_Info "Checking internet connect ..."
Check_Internet $RAINBOND_HOMEPAGE && Echo_Ok || Echo_Error

Echo_Info "Setting [ manage01 ] for hostname ..."
Set_Hostname && Echo_Ok || Echo_Error

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