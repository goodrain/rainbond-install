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
    # 检查 key 函数
    echo "hostname: $DEFAULT_HOSTNAME" >> ./install/pillar/system_info.sls
}


# Name   : Get_Rainbond_Install_Path
# Args   : config_path、config_path_again、install_path
# Return : 0|!0
function Get_Rainbond_Install_Path(){

  read -p $'\t\e[32m使用云帮默认安装路径 (Default:/opt/rainbond) \e[0m (y=yes/c=custom) ' config_path

  if [ "$config_path" == "c" -o "$config_path" == "C" ];then
    read -p $'\t\e[32mInput a installation path\e[0m :' install_path
    # 如果用户未指定，使用默认
    if [ -z $install_path ];then
      install_path=$DEFAULT_INSTALL_PATH
      Echo_Info "Use default path:$DEFAULT_INSTALL_PATH"
    fi

  else
      install_path=$DEFAULT_INSTALL_PATH
      Echo_Info "Use default path:$DEFAULT_INSTALL_PATH"
  fi

  # 检查 key 函数
  echo "rbd-path: $install_path" >> ./install/pillar/system_info.sls
}

# Name   : Install_Salt
# Args   : Null
# Return : 0|!0
function Install_Salt(){
  ./scripts/bootstrap-salt.sh  -M -X -R $SALT_REPO  $SALT_VER 2>&1 > ${LOG_DIR}/${SALT_LOG}

 # echo interface: xx >> /etc/salt/master.d/master.conf
 # echo master: xx >> /etc/salt/minion.d/minion.conf
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
# Args   : public_ips、public_ip、inet_ips、inet_ip、inet_size、
# Return : 0|!0
function Get_Net_Info(){
    public_ips=$(ip ad | grep 'inet ' | grep -vE '( 10.|172.|192.168|127.)' | awk '{print $2}' | cut -d '/' -f 1)
    inet_ips=$(ip ad | grep 'inet ' | egrep ' 10.|172.|192.168' | awk '{print $2}' | cut -d '/' -f 1 | grep -v '172.30.42.1')
    if [ -n $public_ips ];then
      public_ip=$(echo $public_ips | awk '{print $1}')
      echo "public-ip: $pubic_ip" >> $PWD/install/pillar/system_info.sls
    elif [ -n $inet_ips ];then
      inet_size=${#inet_ips}
      if [ $inet_size -le 16 ];then
        check_static $inet_ips 
        if [ $? -ne 0 ];then
          Echo_Info "Error, there is no static net card"
          exit 1
        fi
        Echo_Info "Your inet ip $inet_ips will be used to rainbond"
        echo "inet-ip: $inet_ips" >> $PWD/install/pillar/system_info.sls
      elif [ $inet_size -gt 16 ];then
        read -p $'\t\e[32mPlease choose a inet-ip to use\e[0m (y/n) ' inet_ip
        check_static $inet_ips \ 
        if [ $? -ne 0 ];then
          Echo_Info "Error, there is no static net card"
          exit 1
        else
          default_gateway=$(ip route | grep default | awk '{print $3}')
          curl $default_gateway --connect-timeout 2 >/dev/null
          if [ $? -eq 0 ];then
            Echo_Info "Your inet ip $inet_ip will be used to rainbond"
            echo "inet-ip: $inet_ip" >> $PWD/install/pillar/system_info.sls
          else
            Echo_Info "Can't connect gataway $default_gateway"
            exit 1
          fi
        fi
      fi
    else
      Echo_Info "No ip was found, exit ..."
      exit 1
    fi
}
##########################################################################################
# for each in $(ls -1 /sys/class/net | grep -v lo) ;do
#     result=$(ip addr show $each | awk '$1 == "inet" {gsub(/\/.*$/, "", $2); print $2}' )
#     if [ ! -z "${result// }" ] && [ -d /sys/class/net/${each// } ] ;then
#             echo "Device: $each IP: $result"
#     fi
# done
##########################################################################################

# Name   : check_static
# Args   : ip、net_cards
# Return : 0|!0
function check_static(){
    ip=$1
    net_cards=$(cat /proc/net/dev | awk '{if($2>0 && NR > 2) print substr($1, 0, index($1, ":") - 1)}')
    for net_card in $net_cards
    do
    cat /etc/sysconfig/network-scripts/ifcfg-$net_card | grep $ip
    if [ $? -eq 0 ];then
      cat /etc/sysconfig/network-scripts/ifcfg-$net_card | grep BOOTPROTO | awk -F '=' '{print$2}'
      if [ $? -eq 0 ];then
        return 0
      fi
    fi
    done
}

# Name   : Get_Hardware_Info
# Args   : cpu_num、memory_size、disk
# Return : 0|!0
function Get_Hardware_Info(){

#========================
if ok;then
  return 0
else
  write_log >> error.log
  returen 1
fi
#========================

    cpu_num=$(cat /proc/cpuinfo | grep "processor" | wc -l )
    memory_size=$(free -h | grep Mem | awk '{print $2}')
    if [ $cpu_num -lt 2 ];then
      Echo_Info "There is $cpu_num cpus, you need more cpu, exit ..."
      exit 1
    else
      Echo_Info "There is $cpu_num cpus"
    fi

    if [ $memory_size -lt 2 ];then
      Echo_Info "There is $memory_size memories, you need more memories, exit ..."
      exit 1
    elif [ $memory_size -gt 2 -a $memory_size -lt 4 ];then
      Echo_Info "There is $memory_size memories, It is less than the standard quantity(4 memories), It may affect system performance"
    else
      Echo_Info "There is $memory_size memories"
    fi
}

# Name   : Download_package
# Args   :
# Return : 0|!0
function Download_package(){
  for pkg in $(cat $PWD/etc/package.ls)
  do
    pkg_name=$(echo $pkg | awk -F '/' '{print $1}')
    [ -d $PWD/install/salt/$pkg_name ] \
    && rm -rf $PWD/install/salt/$pkg_name/* \
    || mkdir -p  $PWD/install/salt/$pkg_name/
    if [ ! -f /tmp/$pkg_name.tgz ];then
      curl -s $OSS_DOMAIN/$OSS_PATH/$pkg/$pkg_name.tgz -o /tmp/$pkg_name.tgz
      tar xf /tmp/$pkg_name.tgz -C $PWD/install/salt/$pkg_name/ --strip-components=1
    else
      tar xf /tmp/$pkg_name.tgz -C $PWD/install/salt/$pkg_name/install/ --strip-components=1
    fi
  done

}

# Name   : Write_Config
# Args   :
# Return : 0|!0
function Write_Config(){

cat > /etc/salt/master.d/pillar.conf << END
pillar_roots:
  base:
    - /xxxx/rainbond/install/pillar
END

cat > /etc/salt/master.d/salt.conf << END
file_roots:
  base:
    - /xxxx/rainbond/install/salt
END

# 取出hostname
echo "master: $xxx" > /etc/salt/minion.d/minion.conf 

cp -rp .install/pillar /xxxx/rainbond/install/
cp -rp .install/ /xxxx/rainbond/install/


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