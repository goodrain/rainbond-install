#!/bin/bash

# Function : Check scripts for Rainbond install
# Args     : Null
# Author   : zhouyq (zhouyq@goodrain.com)
# Version  :
# 2018.03.22 first release

. scripts/common.sh

OPT="$1"

# Function : Check internet
# Args     : Check url
# Return   : (0|!0)
function Check_Internet(){
  check_url=$1
  curl -s --connect-timeout 3 $check_url -o /dev/null 2>/dev/null
  if [ $? -eq 0 ];then
    return 0
  else
    err_log "Check if the network is normal"
  fi
}

# Name   : Get_Hostname
# Args   : hostname
# Return : 0|!0
function Init_system(){
  hostname manage01
  echo "manage01" > /etc/hostname
  Write_Sls_File  hostname "$DEFAULT_HOSTNAME"
}


# Name   : Get_Rainbond_Install_Path
# Args   : config_path、config_path_again、install_path
# Return : 0|!0
function Get_Rainbond_Install_Path(){

  if [ ! -z $RBD_PATH ];then
    if [[ "$RBD_PATH" =~ "rainbond" ]];then
      Echo_Info "[$RBD_PATH] is used to installation directory"
    else
      RBD_PATH=$RBD_PATH/rainbond
      Echo_Info "We need a sign for rainbond, what you input is changed to [$RBD_PATH]"
    fi
  else
    RBD_PATH=$DEFAULT_INSTALL_PATH 
  fi
  Write_Sls_File rbd-path $RBD_PATH
}

# Name   : Check_System_Version
# Args   : sys_name、sys_version
# Return : 0|!0
function Check_System_Version(){
    sys_name=$(grep NAME /etc/os-release | head -1)
    sys_version=$(grep VERSION /etc/os-release |  head -1)
       [[ "$sys_version" =~ "7" ]] \
    || [[ "$sys_version" =~ "9" ]] \
    || [[ "$sys_version" =~ "16.04" ]] \
    || err_log "$sys_name$sys_version is not supported temporarily" \
    && return 0
}

# Name   : Get_Net_Info
# Args   : public_ips、public_ip、inet_ips、inet_ip、inet_size、
# Return : 0|!0
function Get_Net_Info(){
  inet_ip=$(ip ad | grep 'inet ' | egrep ' 10.|172.|192.168' | awk '{print $2}' | cut -d '/' -f 1 | grep -v '172.30.42.1' | head -1)
  public_ip=$(ip ad | grep 'inet ' | grep -vE '( 10.|172.|192.168|127.)' | awk '{print $2}' | cut -d '/' -f 1 | head -1)
  net_cards=$(ls -1 /sys/class/net)
  if [ ! -z "$inet_ip" ];then
    for net_card in $net_cards
    do
      grep "$inet_ip" /etc/sysconfig/network-scripts/ifcfg-$net_card \
      && Write_Sls_File inet-ip "${inet_ip}"
    done
  else
    err_log "There is no inet ip"
  fi
  if [ ! -z "$public_ip" ];then
    Write_Sls_File public-ip "${public_ip}"
  fi
  # 写入hosts
  echo "$inet_ip $(hostname)" >> /etc/hosts
}


# Name   : Get_Hardware_Info
# Args   : cpu_num、memory_size、disk
# Return : 0|!0
function Get_Hardware_Info(){
 if [ "$IS_FORCE" == "true" ];then
    echo "[Force install] Ignore cpu and memory limit, It may affect image system performance "
  else
    if [ $CPU_NUM -lt $CPU_LIMIT ] || [ $MEM_SIZE -lt $MEM_LIMIT ];then
      err_log "We need $CPU_LIMIT CPUS,$MEM_LIMIT G Memories. You Have $CPU_NUM CPUS,$MEM_SIZE G Memories"
    else
      info ... ok
    fi
  fi
}



# Name   : Download_package
# Args   :
# Return : 0|!0
function Download_package(){
  curl -s --connect-timeout 3 $OSS_DOMAIN/$OSS_PATH/ctl.md5sum -o ./ctl.md5sum \
  && curl -s --connect-timeout 3 $OSS_DOMAIN/$OSS_PATH/ctl.tgz -o ./ctl.tgz \
  || err_log "The packge is broken, please contact staff to repair"
  
  md5sum -c ./ctl.md5sum > /dev/null 2>&1
  if [ $? -eq 0 ];then
    tar xf .//ctl.tgz -C /usr/local/bin/ --strip-components=1
    return 0
  else
    err_log "The packge is broken, please contact staff to repair"
  fi
  rm ./ctl.* -rf
}

# Name   : Write_Config
# Args   : db_name、db_pass
# Return : 0|!0
function Write_Config(){
  rbd_version=$(cat ./VERSION)
  dns_value=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}')
  # Init database info
  Write_Sls_File db-user "${DB_USER}"
  Write_Sls_File db-pass "${DB_PASS}"
  # Config rbd-version
  Write_Sls_File rbd-version "${rbd_version}"
  # Get current directory
  Write_Sls_File install-script-path "$PWD"
  # Config region info
  Write_Sls_File rbd-tag "cloudbang"
  # Get dns info
  Write_Sls_File dns "$dns_value"
}

# Name   : Install_Salt
# Args   : Null
# Return : 0|!0
function Install_Salt(){
  # install salt without run
  ./scripts/bootstrap-salt.sh  -M -X -R $SALT_REPO  $SALT_VER 2>&1 > ${LOG_DIR}/${SALT_LOG} \
  || err_log "Can't download the salt installation package"

  inet_ip=$(grep inet-ip $PILLAR_DIR/system_info.sls | awk '{print $2}')
  echo "interface: $inet_ip" >> /etc/salt/master.d/master.conf
  echo "master: $(hostname)" >> /etc/salt/minion.d/minion.conf
  echo "id: $(hostname)" >> /etc/salt/minion.d/minion.conf



  # write salt config
cat > /etc/salt/master.d/pillar.conf << END
pillar_roots:
  base:
    - _install_dir_/install/pillar
END
cat > /etc/salt/master.d/salt.conf << END
file_roots:
  base:
    - _install_dir_/install/salt
END
    # auto accept
cat >> /etc/salt/master.d/master.conf <<END
open_mode: True
auto_accept: true
END

    rbd_path=$(grep rbd-path $PILLAR_DIR/system_info.sls | awk '{print $2}')
    sed -i "s#_install_dir_#${rbd_path}#g" /etc/salt/master.d/pillar.conf
    sed -i "s#_install_dir_#${rbd_path}#g" /etc/salt/master.d/salt.conf
    echo "master: $hostname" > /etc/salt/minion.d/minion.conf 
    [ -d ${rbd_path}/rainbond/install/ ] || mkdir -p ${rbd_path}/rainbond/install/
    cp -rp ./install/pillar ${rbd_path}/rainbond/install/
    cp -rp ./install/ ${rbd_path}/rainbond/install/
    systemctl start salt-master || err_log "the service salt-master can't sart ,check the salt-master.service logs"
    systemctl start salt-minion || err_log "the service salt-minion can't sart ,check the salt-minion.service logs"
}


# Name   : Write_Sls_File
# Args   : key
# Return : value
function Write_Sls_File(){
  key=$1
  value=$2
  grep $key $PILLAR_DIR/system_info.sls > /dev/null
  if [ $? -eq 0 ];then
    sed -i -e "/$key/d" $PILLAR_DIR/system_info.sls
  fi
    echo "$key: $value" >> $PILLAR_DIR/system_info.sls
}

function err_log(){
  Echo_Error
  Echo_Info "There seems to be some problem here, You can through the error log(./logs/error.log) to get the detail information"
  echo "$DATE $1" >> ./$LOG_DIR/error.log
  exit 1
}

#=============== main ==============

Echo_Info "Checking internet connect ..."
Check_Internet $RAINBOND_HOMEPAGE && Echo_Ok

Echo_Info "Setting [ manage01 ] for hostname"
Init_system && Echo_Ok

Echo_Info "Configing installation path ..."
Get_Rainbond_Install_Path  && Echo_Ok

Echo_Info "Checking system version ..."
Check_System_Version && Echo_Ok

#ipaddr(inet pub) type .mark in .sls
Echo_Info "Getting net information ..."
Get_Net_Info && Echo_Ok

# disk cpu memory
Echo_Info "Getting Hardware information ..."
Get_Hardware_Info && Echo_Ok

Echo_Info "Downloading Components ..."
Download_package && Echo_Ok

Echo_Info "Writing configuration ..."
Write_Config && Echo_Ok

Echo_Info "Installing salt ..."
Install_Salt && Echo_Ok