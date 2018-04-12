#!/bin/bash
COMPUTE_HOSTNAME=
SYS_NAME=$(grep "^ID=" /etc/os-release | awk -F = '{print $2}'|sed 's/"//g')
SYS_VER=$(grep "^VERSION_ID=" /etc/os-release | awk -F = '{print $2}'|sed 's/"//g')
CPU_NUM=$(grep "processor" /proc/cpuinfo | wc -l )
MEM_SIZE=$(free -h | grep Mem | awk '{print $2}' | cut -d 'G' -f1 | awk -F '.' '{print $1}')
if [ "$SYS_NAME" == "centos" ];then
    DNS_INFO="^DNS"
    NET_FILE="/etc/sysconfig/network-scripts"
else
    DNS_INFO="dns-nameservers"
    NET_FILE="/etc/network/interfaces"
fi

function set_hostname(){
  hostname $COMPUTE_HOSTNAME
  echo $COMPUTE_HOSTNAME > /etc/hostname
}

# check net
function net_test(){
curl -s --connect-timeout 3 https://www.rainbond.com -o /dev/null 2>/dev/null
if [ $? -eq 0 ];then
    return 0
else
    echo "Unable to connect to internet."
    exit 1
fi
}

# check system_version
function system_version(){
  case $SYS_NAME in
  "centos")
    [ "$SYS_VER" == "7" ] \
    && return 0 \
    || ( echo "$SYS_NAME:$SYS_VER is not supported temporarily." && exit 1 )
    ;;
  "ubuntu")
    [ "$SYS_VER" == "16.04" ] \
    && return 0 \
    || ( echo "$SYS_NAME:$SYS_VER is not supported temporarily." && exit 1 )
    ;;
  "debian")
    [ "$SYS_VER" == "8" -o "$SYS_VER" == "9" ] \
    && return 0 \
    || ( echo "$SYS_NAME:$SYS_VER is not supported temporarily." && exit 1 )
    ;;
  *)
    echo "$SYS_NAME:$SYS_VER is not supported temporarily."
    exit 1
    ;;
  esac
}

# check cpu mem
function check_hardware(){
    if [ $CPU_NUM -lt 2 ] || [ $MEM_SIZE -lt 4 ];then
      echo "We need 2 CPUS, 4G Memories. But you Have $CPU_NUM CPUS,$MEM_SIZE G Memories"
      exit 1
    fi
}

# check docker
function check_docker(){
    if $(which docker >/dev/null 2>&1);then
        echo "Rainbond integrated customized docker, Please uninstall it first."
        exit 1
    else
        return 0
    fi
}
# check netcard

function check_netcard(){
    for eth in $(ls -1 /sys/class/net|grep -v lo) ;do 
      ipaddr=$(ip addr show $eth | awk '$1 == "inet" {gsub(/\/.*$/, "", $2); print $2}' )
      if [ "$SYS_NAME" == "centos" ];then
        check_netcard_base $NET_FILE/ifcfg-$eth $ipaddr
      else
        check_netcard_base $NET_FILE $ipaddr
      fi
    done
}

function check_netcard_base(){
  net_file=$1
  ipaddr=$2
  if [ -f $net_file ];then
    isStatic=$(grep "static" $net_file | grep -v "#")
    isIPExist=$(grep "$ipaddr" $net_file | grep -v "#")
    isDNSExist=$(grep "$DNS_INFO" $net_file | grep -v "#")
    
    if [ "$isStatic" == "" ] || [ "$isIPExist" == "" ] ;then
      echo "There is no static ip in $net_file"
      exit 1
    fi
    if [ "$isDNSExist" != "" ];then
      echo "The DNS shouldn't config in $net_file"
      exit 1
    fi
  else
    echo "There is no network config file."
    exit 1
  fi
}


function pre_config_minion(){
  
cat > /tmp/minion.conf <<EOF
master:
id:
EOF
}

set_hostname && echo "hostname is set to $COMPUTE_HOSTNAME"

net_test && echo "net is ok"

system_version && echo "system is ok"

check_hardware && echo "cpu、mem is ok"

check_docker && echo "docker isn't install"

check_netcard && echo "there is static card and no dns config"
# write_uuid && echo "write is ok"

pre_config_minion && echo "pre_config_minion is ok"