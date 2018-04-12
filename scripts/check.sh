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
Check_Internet(){
  check_url=$1
  curl -s --connect-timeout 3 $check_url -o /dev/null 2>/dev/null
  if [ $? -eq 0 ];then
    return 0
  else
    Echo_Error "Unable to connect to internet."
  fi
}


# Name   : Check_Plugins 
# Args   : NULL
# Return : 0|!0
Check_Plugins(){
  if $(which docker >/dev/null 2>&1);then
    Echo_Error "Rainbond integrated customized docker, Please uninstall it first."
  else
    return 0
  fi
  # 检查端口是否被占用
  need_ports="53 80 443 2379 2380 3306 4001 6060 6100 6443 7070 8181 9999"
  for need_port in $need_ports
  do
    (netstat -tulnp | grep "\b$need_port\b") && Echo_Error "The port $need_port has been occupied"
  done
}





# Name   : Check_System_Version
# Args   : NULL
# Return : 0|!0
Check_System_Version(){
  case $SYS_NAME in
  "centos")
    [ "$SYS_VER" == "7" ] \
    && return 0 \
    || Echo_Error "$SYS_NAME:$SYS_VER is not supported temporarily."
    ;;
  "ubuntu")
    [ "$SYS_VER" == "16.04" ] \
    && return 0 \
    || Echo_Error "$SYS_NAME:$SYS_VER is not supported temporarily."
    ;;
  "debian")
    [ "$SYS_VER" == "8" -o "$SYS_VER" == "9" ] \
    && return 0 \
    || Echo_Error "$SYS_NAME:$SYS_VER is not supported temporarily."
    ;;
  *)
    Echo_Error "$SYS_NAME:$SYS_VER is not supported temporarily."
    ;;
  esac
}

# Name   : Get_Net_Info
# Args   : public_ips、public_ip、inet_ips、inet_ip、inet_size、
# Return : 0|!0
Check_Net(){

  eths=($(ls -1 /sys/class/net|grep -v lo))
  if [ ${#eths[@]} -gt 1 ];then
    echo "The system has multiple network cards, please select the device to use:"
    for eth in ${eths[@]}
    do
      ipaddr=$(ip addr show $eth | awk '$1 == "inet" {gsub(/\/.*$/, "", $2); print $2}' )
      isinternal=$(echo $ipaddr | egrep '10.|172.|192.168' | grep -v '172.30.42.1')
      if [ ! -z "$isinternal" ] && [ -z $DEFAULT_LOCAL_IP ];then
        echo "$eth: $ipaddr (default)"
        DEFAULT_LOCAL_IP=$ipaddr
      else
        echo "$eth: $ipaddr"
      fi
    done

    old_ifs=$IFS
    IFS=","
    read -p  "Press Enter to use the default device or input device name ( ${eths[*]} ):" selectip
    IFS=$old_ifs

    if [ "$selectip" != "" ];then
      ipaddr=$(ip addr show $selectip | awk '$1 == "inet" {gsub(/\/.*$/, "", $2); print $2}' )
      if [ "$ipaddr" != "" ];then
        export DEFAULT_LOCAL_IP=$ipaddr
      else
        echo "Select network device error."
      fi
    else
      export DEFAULT_LOCAL_IP
    fi
  else
    DEFAULT_LOCAL_IP=$(ip addr show ${eths[*]} | awk '$1 == "inet" {gsub(/\/.*$/, "", $2); print $2}' )
  fi

  # write sls file
  echo $DEFAULT_LOCAL_IP > ./LOCAL_IP

}


# Name   : Get_Hardware_Info
# Args   : cpu_num、memory_size、disk
# Return : 0|!0
Get_Hardware_Info(){

    if [ $CPU_NUM -lt $CPU_LIMIT ] || [ $MEM_SIZE -lt $MEM_LIMIT ];then
      Echo_Error "Rainbond minimum requirement is ${CPU_LIMIT} CPUs,${MEM_LIMIT}G memory.You Have ${CPU_NUM} CPUs,${MEM_SIZE}G memory."
    fi
}



#=============== main ==============

[ ! -f "/usr/lib/python2.7/site-packages/sitecustomize.py" ] && (
    cp ./scripts/sitecustomize.py /usr/lib/python2.7/site-packages/sitecustomize.py
    Echo_Info "Configure python defaultencoding"
    Echo_Ok
) || (
  Echo_Info "Configure python defaultencoding"
  Echo_Ok
)


if [ "$1" != "force" ];then

  Echo_Info "Checking internet connect ..."
  Check_Internet $RAINBOND_HOMEPAGE && Echo_Ok

  Echo_Info "Check system environment..."
  Check_Plugins && Echo_Ok

  Echo_Info "Check OS version..."
  Check_System_Version && Echo_Ok

  # disk cpu memory
  Echo_Info "Getting Hardware information ..."
  Get_Hardware_Info && Echo_Ok

  #ipaddr(inet pub) type .mark in .sls
  Echo_Info "Getting Network information ..."
  Check_Net && Echo_Ok
else
  Echo_Info "Skip check."
fi

