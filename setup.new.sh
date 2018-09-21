#!/bin/bash
#======================================================================================================================
#
#          FILE: setup.sh
#
#   DESCRIPTION: Install Rainbond Cluster
#
#          BUGS: https://github.com/goodrain/rainbond-install/issues
#
#     COPYRIGHT: (c) 2018 by the Goodrain Delivery Team.
#
#       LICENSE: Apache 2.0
#       CREATED: 08/03/2018 11:38:02 AM
#======================================================================================================================
[[ $DEBUG ]] && set -x

INSTALL_TYPE=${1:-"online"}
MAIN_CONFIG="/srv/pillar/rainbond.sls"
RAINBOND_HOMEPAGE="https://www.rainbond.com"
PILLAR_DIR="./install/pillar"
DOMAIN_API="http://domain.grapps.cn"
SYS_NAME=$(grep "^ID=" /etc/os-release | awk -F = '{print $2}'|sed 's/"//g')
SYS_VER=$(grep "^VERSION_ID=" /etc/os-release | awk -F = '{print $2}'|sed 's/"//g')
CPU_NUM=$(grep "processor" /proc/cpuinfo | wc -l )
CPU_LIMIT=2
MEM_SIZE=$(free -h | grep Mem | awk '{print $2}' | cut -d 'G' -f1)
MEM_LIMIT=4
DEFAULT_LOCAL_IP="$(ip ad | grep 'inet ' | awk '{print $2}' | cut -d '/' -f 1 | egrep '^10\.|^172.|^192.168' | grep -v '172.30.42.1' | head -1)"
DEFAULT_PUBLIC_IP=${2:-"$(ip ad | grep 'inet ' | awk '{print $2}' | cut -d '/' -f 1 | egrep -v '^10\.|^172.|^192.168|^127.' | head -1)"}
INIT_FILE="./.initialized"
YQBIN="/usr/local/bin/yq"
DOMAIN=$3
SYS_COMMON_PKGS=(ntpdate curl net-tools pwgen)
MANAGE_MODULES=(common storage docker image base master worker)
#MANAGE_MODULES=(common storage)
COMPUTE_MODULES=(common storage docker image base worker)

which_cmd() {
    which "${1}" 2>/dev/null || \
        command -v "${1}" 2>/dev/null
}

check_cmd() {
    which_cmd "${1}" >/dev/null 2>&1 && return 0
    return 1
}

setup_terminal() {
    TPUT_RESET=""
    TPUT_BLACK=""
    TPUT_RED=""
    TPUT_GREEN=""
    TPUT_YELLOW=""
    TPUT_BLUE=""
    TPUT_PURPLE=""
    TPUT_CYAN=""
    TPUT_WHITE=""
    TPUT_BGBLACK=""
    TPUT_BGRED=""
    TPUT_BGGREEN=""
    TPUT_BGYELLOW=""
    TPUT_BGBLUE=""
    TPUT_BGPURPLE=""
    TPUT_BGCYAN=""
    TPUT_BGWHITE=""
    TPUT_BOLD=""
    TPUT_DIM=""
    TPUT_UNDERLINED=""
    TPUT_BLINK=""
    TPUT_INVERTED=""
    TPUT_STANDOUT=""
    TPUT_BELL=""
    TPUT_CLEAR=""

    # Is stderr on the terminal? If not, then fail
    test -t 2 || return 1

    if check_cmd tput
    then
        if [ $(( $(tput colors 2>/dev/null) )) -ge 8 ]
        then
            # Enable colors
            TPUT_RESET="$(tput sgr 0)"
            TPUT_BLACK="$(tput setaf 0)"
            TPUT_RED="$(tput setaf 1)"
            TPUT_GREEN="$(tput setaf 2)"
            TPUT_YELLOW="$(tput setaf 3)"
            TPUT_BLUE="$(tput setaf 4)"
            TPUT_PURPLE="$(tput setaf 5)"
            TPUT_CYAN="$(tput setaf 6)"
            TPUT_WHITE="$(tput setaf 7)"
            TPUT_BGBLACK="$(tput setab 0)"
            TPUT_BGRED="$(tput setab 1)"
            TPUT_BGGREEN="$(tput setab 2)"
            TPUT_BGYELLOW="$(tput setab 3)"
            TPUT_BGBLUE="$(tput setab 4)"
            TPUT_BGPURPLE="$(tput setab 5)"
            TPUT_BGCYAN="$(tput setab 6)"
            TPUT_BGWHITE="$(tput setab 7)"
            TPUT_BOLD="$(tput bold)"
            TPUT_DIM="$(tput dim)"
            TPUT_UNDERLINED="$(tput smul)"
            TPUT_BLINK="$(tput blink)"
            TPUT_INVERTED="$(tput rev)"
            TPUT_STANDOUT="$(tput smso)"
            TPUT_BELL="$(tput bel)"
            TPUT_CLEAR="$(tput clear)"
        fi
    fi

    return 0
}
setup_terminal || echo >/dev/null

progress() {
    echo >&2 " --- ${TPUT_DIM}${TPUT_BOLD}${*}${TPUT_RESET} --- "
}

ok() {
    printf >&2 "${TPUT_BGGREEN}${TPUT_WHITE}${TPUT_BOLD} OK ${TPUT_RESET} ${*} \n\n"
}

failed() {
    printf >&2 "${TPUT_BGRED}${TPUT_WHITE}${TPUT_BOLD} FAILED ${TPUT_RESET} ${*} \n\n"
}

error() {
    printf >&2 "${TPUT_BGRED}${TPUT_WHITE}${TPUT_BOLD} Error ${TPUT_RESET} ${*} \n\n"
}

info() {
    printf >&2 " --- ${TPUT_DIM}${TPUT_BOLD}${*}${TPUT_RESET} --- \n\n"
}

fatal() {
    printf >&2 "${TPUT_BGRED}${TPUT_WHITE}${TPUT_BOLD} ABORTED ${TPUT_RESET} ${*} \n\n"
    exit 1
}

which cp | grep "alias" > /dev/null
if [ "$?" -eq 0 ];then
    unalias cp
fi

[ ! -d "/srv/pillar/" ] && (
    mkdir -p /srv/pillar/
    cp rainbond.yaml.default ${MAIN_CONFIG}
)

which yq >/dev/null 2>&1 || (
    cp -a ./scripts/yq /usr/local/bin/yq
    chmod +x /usr/local/bin/yq
)

progress "Start Check System,will install Rainbond $(cat ./VERSION)"
salt_mirrors
if [ "$SYS_NAME" == "centos" ];then
    salt_centos_mirrors
    if [ "$INSTALL_TYPE" == "online" ];then
        ok "Configuring SaltStack online $SYS_NAME mirrors"
    else
        ok "Configuring SaltStack offline $SYS_NAME mirrors"
    fi
elif  [ "$SYS_NAME" == "debian" -o "$SYS_NAME" == "ubuntu" ];then
    salt_debian_mirrors
    if [ "$INSTALL_TYPE" == "online" ];then
        ok "Configuring SaltStack online $SYS_NAME mirrors"
    else
        ok "Configuring SaltStack offline $SYS_NAME mirrors"
    fi
else
    fatal "Only support CentOS/Debian/Ubuntu"
fi

# config centos salt mirrors
salt_centos_mirrors(){
    if [ "$INSTALL_TYPE" == "online" ];then
        cat > /etc/yum.repos.d/salt-repo.repo << END
[saltstack]
name=SaltStack archive/2018.3.2 Release Channel for RHEL/CentOS $releasever
baseurl=http://mirrors.ustc.edu.cn/salt/yum/redhat/7/\$basearch/archive/2018.3.2
skip_if_unavailable=True
failovermethod=priority
gpgcheck=0
enabled=1
enabled_metadata=1
END
        ls /etc/yum.repos.d/ | grep -i epel >/dev/null
        [ $? -ne 0 ] && yum install epel-release -y >/dev/null 2>&1
    else
        mkdir -p /etc/yum.repos.d/backup >/dev/null 2>&1
        mv -f /etc/yum.repos.d/*.repo /etc/yum.repos.d/backup >/dev/null 2>&1
        cat > /etc/yum.repos.d/rainbond.repo << EOF
[rainbond]
name=rainbond_offline_install_repo
baseurl=file:///opt/rainbond/install/install/pkgs/centos/
gpgcheck=0
enabled=1
EOF
    fi
    yum makecache fast -q >/dev/null 2>&1
}

# config debian salt mirrors
salt_debian_mirrors(){
    apt update >/dev/null
    apt install -y -q curl apt-transport-https >/dev/null
    if [ "$INSTALL_TYPE" == "online" ];then
        cat > /etc/apt/sources.list.d/salt.list << END
deb http://mirrors.ustc.edu.cn/salt/apt/debian/9/amd64/2018.3 stretch main
END
    curl https://mirrors.ustc.edu.cn/salt/apt/debian/9/amd64/latest/SALTSTACK-GPG-KEY.pub 2>/dev/null | apt-key add -
    else
         fatal "Not support Now"
    fi
    apt update >/dev/null 2>&1
}

# CentOS install required packages
yum_install_func(){
    local Centos_PKGS=(ntpdate curl net-tools pwgen perl bind-utils dstat iproute bash-completion salt-ssh)
    for pkg in ${Centos_PKGS[@]}
    do
        yum install -y -q $pkg >/dev/null 
    done
    ok "Install required packages successful."
}

# Debian/Ubuntu install required packages
apt_install_func(){
    local Debian_PKGS=(ntpdate curl net-tools pwgen uuid-runtime iproute2 systemd dnsutils python-pip salt-ssh)
    for pkg in ${Debian_PKGS[@]}
    do
        apt install -y -q $pkg >/dev/null
    done
    ok "Install required packages successful."
}

progress "Detect $SYS_NAME required packages..."
case $SYS_NAME in
  "centos")
    [ "$SYS_VER" == "7" ] && yum_install_func || error "$SYS_NAME:$SYS_VER is not supported temporarily."
    ;;
  "ubuntu")
    [ "$SYS_VER" == "16.04" ] && apt_install_func || error "$SYS_NAME:$SYS_VER is not supported temporarily."
    ;;
  "debian")
    [  "$SYS_VER" == "9" ] && apt_install_func || error "$SYS_NAME:$SYS_VER is not supported temporarily."
    ;;
  *)
    error "$SYS_NAME:$SYS_VER is not supported temporarily."
    ;;
esac

# up domain to dns nameserver
reg_status(){
    uid=$( Read_Sls_File reg-uuid $MAIN_CONFIG )
    iip=$( Read_Sls_File master-private-ip $MAIN_CONFIG )
    eip=$( Read_Sls_File master-public-ip $MAIN_CONFIG )
    if [ ! -z "$eip" ];then
        ip=$eip
    else
        ip=$iip
    fi
    domain=$( Read_Sls_File domain $MAIN_CONFIG )
    if [[ "$domain" =~ "grapps" ]];then
        curl --connect-timeout 20 ${DOMAIN_API}/status\?uuid=$uid\&ip=$ip\&type=True\&domain=$domain
    fi
}

# update rainbond.sls
Write_Sls_File(){
    key=$1
    value=$2
    slsfile=${3:-$MAIN_CONFIG}
    isExist=$( $YQBIN r $slsfile $key )
    if [ "$isExist" == "null" ];then
        $YQBIN w -i $slsfile $key "$value"
    fi
}

# get key from rainbond.sls
Read_Sls_File(){
    key=$1
    slsfile=${2:-$MAIN_CONFIG}
    $YQBIN r $slsfile $key
}


#Write_Host(){
#    ipaddr=$1
#    name=${2:-null}
#    if (grep $name /etc/hosts);then
#        sed -i "/$name/d" /etc/hosts
#    fi
#    echo -e "$ipaddr\t$name" >> /etc/hosts
#}

Check_Service_State(){
    sname=$1
    systemctl  is-active $sname > /dev/null 2>&1
}

Install_PKG(){
    pkg_name="$@"
    $INSTALL_BIN install -y -q $pkg_name > /dev/null
}

# check python urllib3 for aliyun (CentOS 7.x)
Check_Python_Urllib(){
    if [ ! -f "$INIT_FILE" ];then
        if ( which pip > /dev/null 2>&1 );then
            if ( pip show urllib3 > /dev/null 2>&1 );then
                if [ "$SYS_NAME" == "centos" ];then
                    pip uninstall urllib3 -y  > /dev/null 2>&1 
                else
                    pip install -U urllib3 > /dev/null 2>&1
                fi
            fi
        fi
    fi
}

#============================== check func  =====================================
Check_Internet(){
  check_url=$1
  curl -s --connect-timeout 15 $check_url -o /dev/null 2>/dev/null
  if [ "$?" -eq 0 ];then
    return 0
  else
    Echo_Error "Unable to connect to internet."
  fi
}

Check_Docker_Version(){

  if (which docker > /dev/null 2>&1 );then
    existDocker=$(docker -v | awk '{print $3$5}' 2>/dev/null)
    grDocker=$(Read_Sls_File docker.version)
    if [ "$existDocker" != "$grDocker" ];then
      Echo_Error "Rainbond integrated customized docker, Please stop and uninstall it first."
    fi
  fi

}

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

Check_Net(){

  eths=($(ls -1 /sys/class/net|grep -v lo))
  default_eths=""
  if [ ${#eths[@]} -gt 1 ];then
    echo "The system has multiple network cards, please select the device to use:"
    for eth in ${eths[@]}
    do
      ipaddr=$(ip addr show $eth | awk '$1 == "inet" {gsub(/\/.*$/, "", $2); print $2}' )
      isinternal=$(echo $ipaddr | egrep '10.|172.|192.168' | grep -v '172.30.42.1')
      if [ ! -z "$isinternal" ] && [ -z $default_eths ];then
        echo "$eth: $ipaddr (default)"
        default_eths=$ipaddr
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
  echo $DEFAULT_LOCAL_IP > /tmp/LOCAL_IP
}

Get_Hardware_Info(){

    CPU_STATUS=$(awk -v num1=$CPU_NUM -v num2=2 'BEGIN{print(num1>=num2)?"0":"1"}')
    MEM_STATUS=$(awk -v num1=$MEM_SIZE -v num2=3 'BEGIN{print(num1>num2)?"0":"1"}')
    if [ "$CPU_STATUS" == '0' -a "$MEM_STATUS" == '0' ];then
      info "Rainbond minimum requirement is ${CPU_LIMIT} CPUs,${MEM_LIMIT}G memory.You Have ${CPU_NUM} CPUs,${MEM_SIZE}G memory."
    else
      Echo_Error "Rainbond minimum requirement is ${CPU_LIMIT} CPUs,${MEM_LIMIT}G memory.You Have ${CPU_NUM} CPUs,${MEM_SIZE}G memory."
    fi
}

# check system
system_check(){

  progress "Checking internet connect ..."
  if [ "$INSTALL_TYPE" == "online" ];then
        Check_Internet $RAINBOND_HOMEPAGE && ok
  else
        ok
  fi

  progress "Check system environment..."
  Check_Docker_Version && ok

  # disk cpu memory
  progress "Getting Hardware information ..."
  Get_Hardware_Info && ok

  #ipaddr(inet pub) type .mark in .sls
  progress "Getting Network information ..."
  Check_Net && ok
}

#============================== init func  =====================================

Init_system(){
  # configure ip address
  LOCAL_IP=$(cat ./LOCAL_IP 2> /dev/null)
  DEFAULT_LOCAL_IP=${LOCAL_IP:-$DEFAULT_LOCAL_IP}
  Write_Sls_File master-private-ip $DEFAULT_LOCAL_IP
  Write_Sls_File vip $DEFAULT_LOCAL_IP
  if [[ "$DEFAULT_PUBLIC_IP" == "0.0.0.0" ]];then
    DEFAULT_PUBLIC_IP="$(ip ad | grep 'inet ' | awk '{print $2}' | cut -d '/' -f 1 | egrep -v '^10\.|^172.|^192.168|^127.' | head -1)"
    Write_Sls_File master-public-ip "${DEFAULT_PUBLIC_IP}"
  else
    Write_Sls_File master-public-ip "${DEFAULT_PUBLIC_IP}"
  fi

  # configure hostname and hosts
  # reset /etc/hosts
  echo -e "127.0.0.1\tlocalhost" > /etc/hosts
  MASTER_HOSTNAME=$(Read_Sls_File master-hostname)
  hostname -b $MASTER_HOSTNAME
  echo $MASTER_HOSTNAME > /etc/hostname
  #Write_Host "${DEFAULT_LOCAL_IP}" "${MASTER_HOSTNAME}"

  # Get current directory
  Write_Sls_File install-script-path "$PWD"

  # Get dns and write global dns info
  dns_value=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}' | head -1)
  Write_Sls_File dns.current "$dns_value"

  # generate secretkey
  secretkey=$(pwgen 32 1)
  Write_Sls_File secretkey "${secretkey:-auv2aequ1dahj9GameeGam9fei8Kohng}"

  #judgment below uses for offline env : do not exec ntp cmd ( changed by guox 2018.5.18 ).
  if [ "$INSTALL_TYPE" == "online" ];then
    progress "update localtime"
    ntpdate ntp1.aliyun.com ntp2.aliyun.com ntp3.aliyun.com > /dev/null 2>&1 && ok
  else
    return 0
  fi

  #config domain
  if [ ! -z "$DOMAIN" ];then
        Write_Sls_File domain $DOMAIN
  fi
}

run(){

    ## Generate random user & password
    DB_USER=write
    DB_PASS=$(echo $((RANDOM)) | base64 | md5sum | cut -b 1-8)
    DB_TYPE=$(Read_Sls_File database.type)

    Write_Sls_File database.$DB_TYPE.host ${DEFAULT_LOCAL_IP}
    Write_Sls_File database.$DB_TYPE.user ${DB_USER}
    Write_Sls_File database.$DB_TYPE.pass ${DB_PASS}

    Write_Sls_File etcd.server.bind.host ${DEFAULT_LOCAL_IP}
    Write_Sls_File etcd.server.token $(uuidgen)
    Write_Sls_File etcd.server.members[0].host ${DEFAULT_LOCAL_IP}
    Write_Sls_File etcd.server.members[0].name ${MASTER_HOSTNAME}
    Write_Sls_File etcd-endpoints "http://${DEFAULT_LOCAL_IP}:2379"

    IP_INFO=$(ip ad | grep 'inet ' | egrep ' 10.|172.|192.168' | awk '{print $2}' | cut -d '/' -f 1 | grep -v '172.30.42.1')
    IP_ITEMS=($IP_INFO)
    INET_IP=${IP_ITEMS%%.*}
    if [[ $INET_IP == '172' ]];then
        CALICO_NET=10.0.0.0/16
    elif [[ $INET_IP == '10' ]];then
        CALICO_NET=172.16.0.0/16
    else
        CALICO_NET=172.16.0.0/16
    fi

    Write_Sls_File network.calico.bind ${DEFAULT_LOCAL_IP}
    Write_Sls_File network.calico.net ${CALICO_NET}

    Write_Sls_File lb-endpoints "http://${DEFAULT_LOCAL_IP}:10002"

    cat > ${PILLAR_DIR}/top.sls <<EOF
base:
  '*':
    - rainbond
EOF
}


# salt-ssh install salt-master,salt-minion
Install_Salt(){

  # check python env
  info "Check python environment ..."
  Check_Python_Urllib && ok

  inet_ip=$(Read_Sls_File "master-private-ip" )

cat > /etc/salt/roster <<EOF
manage01:
  host: $inet_ip
  port: 22
  user: root
  sudo: True
  tty: True
  priv: /etc/salt/pki/master/ssh/salt-ssh.rsa
EOF

    [ -d "/root/.ssh" ] || (mkdir -p /root/.ssh && chmod 700 /root/.ssh )
    [ -f "/etc/salt/pki/master/ssh/salt-ssh.rsa.pub" ] && cat /etc/salt/pki/master/ssh/salt-ssh.rsa.pub >> /root/.ssh/authorized_keys || (
  salt-ssh "*" w >/dev/null 2>&1 || cat /etc/salt/pki/master/ssh/salt-ssh.rsa.pub >> /root/.ssh/authorized_keys
)

  [ ! -d "~/.ssh/id_rsa" ] && (
    cp -a /etc/salt/pki/master/ssh/salt-ssh.rsa ~/.ssh/id_rsa
    cp -a /etc/salt/pki/master/ssh/salt-ssh.rsa.pub ~/.ssh/id_rsa.pub
  )
  
  cp -rp $PWD/install/salt /srv/
  
  cp -rp $PWD/install/pillar/top.sls /srv/pillar/top.sls

  info "Salt-ssh test."
  salt-ssh "*" --priv=/etc/salt/pki/master/ssh/salt-ssh.rsa  test.ping -i > /dev/null && ok
  progress "Install Salt-Master & Salt-Minion"
  salt-ssh "*" state.sls salt.setup --state-output=mixed
  
  info "Waiting to start salt."
  for ((i=1;i<=60;i++ )); do
    echo -e -n "."
    sleep 1
    uuid=$(timeout 3 salt "*" grains.get uuid | grep '-' | awk '{print $1}')
    [ ! -z "$uuid" ] && (
      Write_Sls_File reg-uuid "$uuid" $MAIN_CONFIG
    ) && break
  done
}

Init_Config_Func(){

    Write_Sls_File install-type "$INSTALL_TYPE"

    progress "Init system config ..."
    Init_system && ok

    progress "Init config ..."
    run && ok

    Install_Salt && ok
}

#================================ setup rainbond  =========================================
#check_func(){
#    progress "check system func."
#    System_Check
#}

config(){
    if [ ! -f "$INIT_FILE" ];then
        progress "Init rainbond configure."
        Init_Config_Func && touch $INIT_FILE
    fi
}

install_func(){
    fail_num=0
    step_num=1
    all_steps=${#MANAGE_MODULES[@]}
    progress "will install manage node.It will take 15-30 minutes to install"
  
    for module in ${MANAGE_MODULES[@]}
    do
        if [ "$module" = "image" ];then
            info "Start install $module(step: $step_num/$all_steps), it will take 8-15 minutes "
            info "This step will pull/load all docker images"
        else
            info "Start install $module(step: $step_num/$all_steps) ..."
        fi
        if ! (salt "*" state.sls $module);then
            ((fail_num+=1))
            break
        fi
        ((step_num++))
        sleep 1
    done

    if [ "$fail_num" -eq 0 ];then
        if [ "$INSTALL_TYPE" == "online" ];then
            reg_status || return 0
        fi
        
        uuid=$(salt '*' grains.get uuid | grep "-" | awk '{print $1}')
        if [ -z "$uuid" ];then
            fatal "Please check node status[uuid], Just Run systemctl status node"
            exit 1
        fi
        for ((i=1;i<=60;i++ ));do
            sleep 1
            notready=$(grctl node list | grep $uuid | grep offline)
            [ ! -z "$notready" ] && (
                grctl node up $uuid
            ) && break
        done
        info "Install Rainbond successfully"

        docker images | grep "rainbond" | awk '{print $1":"$2}' | xargs -I {} docker rmi {} >/dev/null 2>&1

        public_ip=$(yq r /srv/pillar/rainbond.sls master-public-ip)
        private_ip=$(yq r /srv/pillar/rainbond.sls master-private-ip)
        for ((i=1;i<=60;i++ ));do
            sleep 1
            status_code=$(curl -s -I http://127.0.0.1:7070  | head -1 | awk '{print $2}')
            check_code=$(awk -v num1=$status_code -v num2=400 'BEGIN{print(num1<num2)?"0":"1"}')
            [ "$check_code" == "0" ] && (
                if [ ! -z "$public_ip" ];then
                    #echo_banner "http://${public_ip}:7070"
                    echo "${public_ip}" > /opt/rainbond/envs/.exip
                else
                    #echo_banner "http://${private_ip}:7070"
                    echo "${private_ip}" > /opt/rainbond/envs/.exip
                fi
            ) && break
        done
    else
        failed "install failed... get help from https://t.goodrain.com"
        exit 1
    fi
}

case $1 in
    *)
        system_check && config && install_func
    ;;
esac
