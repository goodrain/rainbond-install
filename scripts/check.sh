#!/bin/bash

# Function : Check scripts for Rainbond install
# Args     : Null
# Author   : zhouyq (zhouyq@goodrain.com)
# Version  :
# 2018.03.22 first release

. scripts/common.sh

# Function : Init
# Args     : 
# Return   : 
function Init(){
  [ ! -f ./install/pillar/system_info.sls ] \
  &&touch ./install/pillar/system_info.sls
}


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
    echo "manage01" > /etc/hostname
    Check_Sls_File hostname 
    echo "hostname: $DEFAULT_HOSTNAME" >> ./install/pillar/system_info.sls
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
  Check_Sls_File rbd-path
  echo "rbd-path: $install_path" >> ./install/pillar/system_info.sls
}

# Name   : Install_Salt
# Args   : Null
# Return : 0|!0
function Install_Salt(){
  ./scripts/bootstrap-salt.sh  -M -X -R $SALT_REPO  $SALT_VER 2>&1 > ${LOG_DIR}/${SALT_LOG}
  # write salt config
  [ -f /etc/salt/master.d/pillar.conf ] \
  && rm /etc/salt/master.d/pillar.conf -rf 
  [ -f /etc/salt/master.d/salt.conf ] \
  && rm  /etc/salt/master.d/salt.conf -rf
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
    rbd-path=$(cat ./install/pillar/system_info.sls | grep rbd-path | awk '{print $2}')
    sed "s/_install_dir_/${rbd-path}/g" /etc/salt/master.d/pillar.conf
    sed "s/_install_dir_/${rbd-path}/g" /etc/salt/master.d/salt.conf
    echo "master: $hostname" > /etc/salt/minion.d/minion.conf 
    cp -rp .install/pillar /${rbd-path}/rainbond/install/
    cp -rp .install/ /${rbd-path}/rainbond/install/
    systemctl start salt-master
    systemctl start salt-minion
}


# Name   : Check_System_Version
# Args   : sys_name、sys_version
# Return : 0|!0
function Check_System_Version(){
    sys_name=$(cat /etc/os-release | grep NAME | head -1)
    sys_version=$(cat /etc/os-release | grep VERSION | head -1)

       [[ $sys_name != *CentOS* ]] \
    || [[ $sys_name != *Ubuntu* ]] \
    || [[ $sys_name != *Debian* ]] \
    || ( Write_File err_log "$sys_name$sys_version is not supported temporarily" > ./logs/error.log
        exit 1 )
    
       [[ $sys_version != *7* ]] \
    || [[ $sys_version != *9* ]] \
    || [[ $sys_version != *16.04* ]] \
    || ( Write_File err_log "$sys_name$sys_version is not supported temporarily" > ./logs/error.log
        exit 1)
}

# Name   : Get_Net_Info
# Args   : public_ips、public_ip、inet_ips、inet_ip、inet_size、
# Return : 0|!0
function Get_Net_Info(){
  Check_Sls_File public-ip
  Check_Sls_File inet-ip
  for net_card in $(ls -1 /sys/class/net) ;do 
    ip=$(ip addr show $net_card | awk '$1 == "inet" {gsub(/\/.*$/, "", $2); print $2}' )
    if [ ! -z "${ip// }" ] && [ -d /sys/class/net/${net_card// } ] ;then
      public_ip=$(echo $ip | grep -vE '( 10.|172.|192.168|127.)')
      inet_ip=$(echo $ip | egrep ' 10.|172.|192.168' | grep -v '172.30.42.1')
      grep 'static' /etc/sysconfig/network-scripts/ifcfg-$net_card
      if [ $? -eq 0 ];then
        if [ ${#public_ip} -gt 7 ];then
          grep 'public-ip' ./install/pillar/system_info.sls
          if [ $? -ne 0 ];then
            echo "public-ip: $pubic_ip" >> ./install/pillar/system_info.sls
          fi
        elif [ ${#inet_ip } -gt 7 ];then
          grep 'public-ip' ./install/pillar/system_info.sls
          if [ $? -ne 0 ];then
            echo "inet-ip: $inet_ip" >> ./install/pillar/system_info.sls
          fi
        fi
      else
        Write_File err_log "there isn't a static net-card"
        exit 1
      fi
      break;
    fi
done
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
  if [ -f /tmp/ctl.tgz ];then
    curl -s $OSS_DOMAIN/$OSS_PATH/ctl.md5 -o /tmp/ctl.md5
    md5sum -c /tmp/ctl.md5 > /dev/null 2>&1
      if [ $? -eq 0 ];then
        tar xf /tmp/ctl.tgz -C /usr/local/bin/ --strip-components=1
        return 0
      else
        curl -s $OSS_DOMAIN/$OSS_PATH/ctl.tgz -o /tmp/ctl.tgz
        md5sum -c /tmp/ctl.md5 > /dev/null 2>&1
        if [ $? -eq 0 ];then
          tar xf /tmp/ctl.tgz -C /usr/local/bin/ --strip-components=1
          return 0
        else
          Write_File err_log "The packge is broken, please contact staff to repair."
          exit 1
        fi
      fi
    rm /tmp/ctl.* -rf
  fi
}

# Name   : Write_Config
# Args   : db_name、db_pass
# Return : 0|!0
function Write_Config(){
    db_name=admin
    db_pass=$(shuf -i 100000-999999 -n 1)
    Check_Sls_File db-Name \
    && Write_File add "db-name : $db_name"  ./install/pillar/system_info.sls
    Check_Sls_File db-pass \
    && Write_File add "db-pass : $db_pass"  ./install/pillar/system_info.sls
}

# Name   : Check_Sls_File
# Args   : key
# Return : none
function Check_Sls_File(){
  key=$1
    grep $key ./install/pillar/system_info.sls 
    if [ $? -eq 0 ];then
        sed -i -e "/$key/d" ./install/pillar/system_info.sls
    fi
}

# Name   : Write_File
# Args   : none
# Return : none
function Write_File(){
  if [ "$1" == "add" ];then
    echo $2 >> $3
  elif [ "$1" == "err_log" ];then
    echo "$DATE :$2" > ./logs/error.log
    Echo_Info "There seems to be some wrong here, you can check out the error logs in you installation dir (logs/error.log)"
  else
    echo $2 > $3
  fi
}

#=============== main ==============

Echo_Info "Initing ..."
Init

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