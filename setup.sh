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

RBD_VERSION=$(cat ./VERSION 2> /dev/null)
SALT_PKGS="salt-ssh"
MAIN_CONFIG="/srv/pillar/rainbond.sls"
RAINBOND_HOMEPAGE="https://www.rainbond.com"
PILLAR_DIR="./install/pillar"
DOMAIN_API="http://domain.grapps.cn"
K8S_SERVICE=( kube-controller-manager kube-scheduler kube-apiserver kubelet)
RAINBOND_SERVICE=( etcd node calico )
SYS_NAME=$(grep "^ID=" /etc/os-release | awk -F = '{print $2}'|sed 's/"//g')
SYS_VER=$(grep "^VERSION_ID=" /etc/os-release | awk -F = '{print $2}'|sed 's/"//g')
CPU_NUM=$(grep "processor" /proc/cpuinfo | wc -l )
CPU_LIMIT=2
MEM_SIZE=$(free -h | grep Mem | awk '{print $2}' | cut -d 'G' -f1)
MEM_LIMIT=4
DEFAULT_LOCAL_IP="$(ip ad | grep 'inet ' | awk '{print $2}' | cut -d '/' -f 1 | egrep '^10\.|^172.|^192.168' | grep -v '172.30.42.1' | head -1)"
DEFAULT_PUBLIC_IP=${2:-"$(ip ad | grep 'inet ' | awk '{print $2}' | cut -d '/' -f 1 | egrep -v '^10\.|^172.|^192.168|^127.' | head -1)"}
INIT_FILE="./.initialized"
OFFLINE_FILE="./.offlineprepared"
DOMAIN=$3
MANAGE_MODULES="common \
storage \
docker \
image \
base \
master \
worker"

COMPUTE_MODULES="common \
storage \
docker \
image \
base \
worker"

# system common pkgs
SYS_COMMON_PKGS=( tar \
ntpdate \
wget \
curl \
net-tools \
pwgen \
git )

 # trap program exit
trap 'Exit_Clear; exit' SIGINT SIGHUP
clear

which cp | grep "alias" > /dev/null
if [ "$?" -eq 0 ];then
    unalias cp
fi

[ ! -d "/srv/pillar/" ] && (
    mkdir -p /srv/pillar/
    cp rainbond.yaml.default ${MAIN_CONFIG}
)

which yq >/dev/null 2>&1 || (
    if [ "$INSTALL_TYPE" == "online" ];then
        curl -s https://pkg.rainbond.com/releases/common/yq -o /usr/local/bin/yq
        chmod +x /usr/local/bin/yq
    else
        cp -a ./scripts/yq /usr/local/bin/yq
        chmod +x /usr/local/bin/yq
    fi
)

YQBIN="/usr/local/bin/yq"

# redhat and centos
if [ "$SYS_NAME" == "centos" ];then
    INSTALL_BIN="yum"
    Cache_PKG="$INSTALL_BIN makecache fast -q"
    PKG_BIN="rpm -qi"
    SYS_BASE_PKGS=( perl \
    bind-utils \
    dstat iproute \
    bash-completion )

    if [ "$INSTALL_TYPE" == "online" ] ;then
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

        [ ! -f "/etc/yum.repos.d/epel.repo" ] && (
            curl -s -o /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
            yum makecache fast >/dev/null 2>&1
        ) || (
            yum install epel-release -y >/dev/null 2>&1
            yum makecache fast >/dev/null 2>&1
        )     
    else
        mkdir -p /etc/yum.repos.d/backup >/dev/null 2>&1
    mv -f /etc/yum.repos.d/*.repo /etc/yum.repos.d/backup >/dev/null 2>&1
    cat > /etc/yum.repos.d/rainbond_local.repo << EOF
[rainbond_local]
name=rainbond_offline_install_repo
baseurl=file:///opt/rainbond/install/install/pkgs/centos/
gpgcheck=0
enabled=1
EOF
    rpm -ivh /opt/rainbond/install/install/pkgs/centos/deltarpm-*.rpm 1>/dev/null 
    rpm -ivh /opt/rainbond/install/install/pkgs/centos/libxml2-python-*.rpm  1>/dev/null 
    rpm -ivh /opt/rainbond/install/install/pkgs/centos/python-deltarpm-*.rpm  1>/dev/null 
    rpm -ivh /opt/rainbond/install/install/pkgs/centos/createrepo-*.rpm  1>/dev/null

    createrepo /opt/rainbond/install/install/pkgs/centos/  1>/dev/null
    fi

else
    INSTALL_BIN="apt-get"
    Cache_PKG="$INSTALL_BIN update -y -q"
    PKG_BIN="dpkg -l"
    SYS_BASE_PKGS=( uuid-runtime \
    iproute2 \
    systemd \
    dnsutils \
    python-pip \
    apt-transport-https )
    curl https://mirrors.ustc.edu.cn/salt/apt/debian/9/amd64/latest/SALTSTACK-GPG-KEY.pub 2>/dev/null | apt-key add -
    # debian salt repo
    cat > /etc/apt/sources.list.d/salt.list << END
deb https://mirrors.ustc.edu.cn/salt/apt/debian/9/amd64/2018.3 stretch main
END
fi

#=================== base show func ==========================================
which_cmd() {
    which "${1}" 2>/dev/null || \
        command -v "${1}" 2>/dev/null
}

check_cmd() {
    which_cmd "${1}" >/dev/null 2>&1 && return 0
    return 1
}

if [ $(( $(tput colors 2>/dev/null) )) -ge 8 ];then
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

echo_banner() {

local l1=" ^" \
      l2=" |  ____       _       _                     _                               " \
      l3=" | |  _ \ __ _(_)_ __ | |__   ___  _ __   __| |                              " \
      l4=" | | |_) / _\` | | '_ \| '_ \ / _  | '_ \ / _\` |                              " \
      l5=" | |  _ < (_| | | | | | |_) | (_) | | | | (_| |                              " \
      l6=" | |_| \_\__,_|_|_| |_|_.__/ \___/|_| |_|\__,_|                              " \
      l7=" +----+-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+--->" \
      sp="                                                                             " \
      rbd="Goodrain Rainbond" start end msg="${*}" chartcolor="${TPUT_DIM}"
      
    [ ${#msg} -lt ${#rbd} ] && msg="${msg}${sp:0:$(( ${#rbd} - ${#msg}))}"
    [ ${#msg} -gt $(( ${#l4} - 20 )) ] && msg="${msg:0:$(( ${#l4} - 23 ))}..."

    start="$(( ${#l4} ))"
    [ $(( start + ${#msg} + 4 )) -gt ${#l4} ] && start=$((${#l4} - ${#msg} - 4))
    end=$(( ${start} + ${#msg} + 4 ))
    echo >&2
    echo >&2 "${chartcolor}${l1}${TPUT_RESET}"
    echo >&2 "${chartcolor}${l2}${TPUT_RESET}"
    echo >&2 "${chartcolor}${l3}${TPUT_RESET}"
    echo >&2 "${chartcolor}${l4:0:start}${sp:0:2}${TPUT_RESET}${TPUT_BOLD}${TPUT_GREEN}${rbd}${TPUT_RESET}${chartcolor}${sp:0:$((end - start - 2 - ${#netdata}))}${l4:end:$((${#l4} - end))}${TPUT_RESET}"
    echo >&2 "${chartcolor}${l5:0:start}${sp:0:2}${TPUT_RESET}${TPUT_BOLD}${TPUT_CYAN}${msg}${TPUT_RESET}${chartcolor}${sp:0:2}${l5:end:$((${#l5} - end))}${TPUT_RESET}"
    echo >&2 "${chartcolor}${l6}${TPUT_RESET}"
    echo >&2 "${chartcolor}${l7}${TPUT_RESET}"
    echo >&2
}

Echo_Failed() {
    printf >&2 "${TPUT_BGRED}${TPUT_WHITE}${TPUT_BOLD} FAILED ${TPUT_RESET} ${*} \n\n"
}

Echo_Error() {
    printf >&2 "${TPUT_BGRED}${TPUT_WHITE}${TPUT_BOLD} FAILED ${TPUT_RESET} ${*} \n\n"
    exit 1
}

Echo_Exist() {
    printf >&2 "${TPUT_BGRED}${TPUT_WHITE}${TPUT_BOLD} EXIST ${TPUT_RESET} ${*} \n\n"
}

Echo_Info() {
    echo >&2 " --- ${TPUT_DIM}${TPUT_BOLD}${*}${TPUT_RESET} --- "
}

Echo_Ok() {
   printf >&2 "${TPUT_BGGREEN}${TPUT_WHITE}${TPUT_BOLD} OK ${TPUT_RESET} ${*} \n\n"
}

REG_Status(){
    uid=$( Read_Sls_File reg-uuid $MAIN_SLS )
    iip=$( Read_Sls_File master-private-ip $MAIN_SLS )
    eip=$( Read_Sls_File master-public-ip $MAIN_SLS )
    if [ ! -z "$eip" ];then
        ip=$eip
    else
        ip=$iip
    fi
    domain=$( Read_Sls_File domain $MAIN_SLS )
    if [[ "$domain" =~ "grapps" ]];then
        curl --connect-timeout 20 ${DOMAIN_API}/status\?uuid=$uid\&ip=$ip\&type=True\&domain=$domain
        echo ""
    else
        echo ""
    fi
}

Write_Host(){
    ipaddr=$1
    name=${2:-null}
    if (grep $name /etc/hosts);then
        sed -i "/$name/d" /etc/hosts
    fi
    echo -e "$ipaddr\t$name" >> /etc/hosts
}

Check_Service_State(){
    sname=$1
    systemctl  is-active $sname > /dev/null 2>&1
}

Install_PKG(){
    pkg_name="$@"
    $INSTALL_BIN install -y -q $pkg_name > /dev/null
}

Write_Sls_File(){
    key=$1
    value=$2
    slsfile=${3:-$MAIN_CONFIG}
    isExist=$( $YQBIN r $slsfile $key )
    if [ "$isExist" == "null" ];then
        $YQBIN w -i $slsfile $key "$value"
    fi
}

Read_Sls_File(){
    key=$1
    slsfile=${2:-$MAIN_CONFIG}
    $YQBIN r $slsfile $key
}

Exit_Clear() {
    echo -e "\e[31mQuit rainbond install program.\e[0m"
    Echo_Info "Restore dns configuration ..."
    [ -f /etc/resolv.conf.bak ] && \cp -f /etc/resolv.conf.bak /etc/resolv.conf && Echo_Ok

    Echo_Info "Checking salt job ..."
    if (which salt-run > /dev/null 2>&1);then
        saltjob=$(salt-run jobs.active --out=yaml | head -n 1| sed -e "s/'//g" -e 's/://')
        if [ "$saltjob" != "{}" ];then
            Echo_Info "Stop salt job ..."
            salt '*' saltutil.term_job $saltjob && Echo_Ok
        fi
    fi
    Echo_Info "Terminate running services ..."
    Echo_Info "  Checking k8s services ..."
    for kservice in ${K8S_SERVICE[*]}
    do
        Check_Service_State $kservice && systemctl stop $kservice 
    done

    Echo_Info "  Checking rainbond services ..."
    for rservice in ${RAINBOND_SERVICE[*]}
    do
        Check_Service_State $rservice && systemctl stop $rservice 
    done
    if $(which dc-compose > /dev/null 2>&1);then
        if $(dc-compose ps > /dev/null 2>&1);then
            dc-compose stop && cclear
        fi
    fi

    Echo_Info "  Checking docker ..."
    Check_Service_State docker && systemctl stop docker && Echo_Ok

    Echo_Info "  Clear rainbond data ..."

    if (which salt-run > /dev/null 2>&1);then
        rbdpath=$(salt '*' pillar.item rbd-path --output=yaml | grep rbd-path | awk '{print $2}')
        if [ "$rbdpath" != "" ];then
            [ -d "$rbdpath/data" ] && rm -rf $rbdpath/data && Echo_Ok
        fi
    fi
    
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
      Echo_Info "Rainbond minimum requirement is ${CPU_LIMIT} CPUs,${MEM_LIMIT}G memory.You Have ${CPU_NUM} CPUs,${MEM_SIZE}G memory."
    else
      Echo_Error "Rainbond minimum requirement is ${CPU_LIMIT} CPUs,${MEM_LIMIT}G memory.You Have ${CPU_NUM} CPUs,${MEM_SIZE}G memory."
    fi
}

System_Check(){
[ ! -f "/usr/lib/python2.7/site-packages/sitecustomize.py" ] && (
    [ ! -d "/usr/lib/python2.7/site-packages/" ] || cp ./scripts/sitecustomize.py /usr/lib/python2.7/site-packages/sitecustomize.py
    Echo_Info "Configure python defaultencoding"
    Echo_Ok
) || (
  Echo_Info "Configure python defaultencoding"
  Echo_Ok
)

  Echo_Info "Checking internet connect ..."
  if [ "$INSTALL_TYPE" == "online" ];then
        Check_Internet $RAINBOND_HOMEPAGE && Echo_Ok
  else
        Echo_Ok
  fi

  Echo_Info "Check system environment..."
  Check_Docker_Version && Echo_Ok

  Echo_Info "Check OS version..."
  Check_System_Version && Echo_Ok

  # disk cpu memory
  Echo_Info "Getting Hardware information ..."
  Get_Hardware_Info && Echo_Ok

  #ipaddr(inet pub) type .mark in .sls
  Echo_Info "Getting Network information ..."
  Check_Net && Echo_Ok
}
#============================== init func  =====================================

Init_system(){
  # configure ip address
  LOCAL_IP=$(cat ./LOCAL_IP 2> /dev/null)
  DEFAULT_LOCAL_IP=${LOCAL_IP:-$DEFAULT_LOCAL_IP}
  Write_Sls_File master-private-ip $DEFAULT_LOCAL_IP
  Write_Sls_File vip $DEFAULT_LOCAL_IP
  Write_Sls_File master-public-ip "${DEFAULT_PUBLIC_IP}"
  
  # configure hostname and hosts
  # reset /etc/hosts
  echo -e "127.0.0.1\tlocalhost" > /etc/hosts
  MASTER_HOSTNAME=$(Read_Sls_File master-hostname)
  hostname -b $MASTER_HOSTNAME
  echo $MASTER_HOSTNAME > /etc/hostname
  Write_Host "${DEFAULT_LOCAL_IP}" "${MASTER_HOSTNAME}"

  # Get current directory
  Write_Sls_File install-script-path "$PWD"

  # Get dns and write global dns info
  dns_value=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}' | head -1)
  Write_Sls_File dns.current "$dns_value"

  # generate secretkey
  secretkey=$(pwgen 32 1)
  Write_Sls_File secretkey "${secretkey:-auv2aequ1dahj9GameeGam9fei8Kohng}"

  #judgment below uses for offline env : do not exec ntp cmd ( changed by guox 2018.5.18 ).
  if [[ "$INSTALL_TYPE" != "offline" ]];then
    Echo_Info "update localtime"
    ntpdate ntp1.aliyun.com ntp2.aliyun.com ntp3.aliyun.com > /dev/null 2>&1 && Echo_Ok
  else
    return 0
  fi

  #config domain
  if [ ! -z "$DOMAIN" ];then
        Write_Sls_File domain $DOMAIN
  fi
}

# Name   : Install_Base_Pkg
# Args   : NULL
# Return : 0|!0
Install_Base_Pkg(){

  # make repo cache
  $Cache_PKG

  # install pkgs
  Install_PKG  ${SYS_BASE_PKGS[*]} ${SYS_COMMON_PKGS[*]}
}

# -----------------------------------------------------------------------------
# init database configure

db_init() {

## Generate random user & password
DB_USER=write
DB_PASS=$(echo $((RANDOM)) | base64 | md5sum | cut -b 1-8)
DB_TYPE=$(Read_Sls_File database.type)

Write_Sls_File database.$DB_TYPE.host ${DEFAULT_LOCAL_IP}
Write_Sls_File database.$DB_TYPE.user ${DB_USER}
Write_Sls_File database.$DB_TYPE.pass ${DB_PASS}

}

# -----------------------------------------------------------------------------
# init etcd configure

etcd(){

Write_Sls_File etcd.server.bind.host ${DEFAULT_LOCAL_IP}
Write_Sls_File etcd.server.token $(uuidgen)
Write_Sls_File etcd.server.members[0].host ${DEFAULT_LOCAL_IP}
Write_Sls_File etcd.server.members[0].name ${MASTER_HOSTNAME}

Write_Sls_File etcd-endpoints "http://${DEFAULT_LOCAL_IP}:2379"

}

# -----------------------------------------------------------------------------
# init etcd configure
entrance(){
  Write_Sls_File lb-endpoints "http://${DEFAULT_LOCAL_IP}:10002"
}


# -----------------------------------------------------------------------------
# init network-calico configure
calico(){

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

}


# -----------------------------------------------------------------------------
# init top configure
write_top(){
cat > ${PILLAR_DIR}/top.sls <<EOF
base:
  '*':
    - rainbond
EOF
}

run(){
    db_init
    etcd
    calico
    entrance
    write_top
}


# Name   : Install_Salt
# Args   : Null
# Return : 0|!0
Install_Salt(){

  # check python env
  Echo_Info "Check python environment ..."
  Check_Python_Urllib && Echo_Ok
  
  # check salt service
  Echo_Info "Checking salt ..."
  Check_Service_State salt-master && systemctl stop salt-master
  Check_Service_State salt-minion && systemctl stop salt-minion

  # check and install salt 
  if [ ! "$SALT_SSH_INSTALLED" ];then
    # update repo mate
    Echo_Info "Installing salt ..."
    $Cache_PKG > /dev/null

    # install salt
    Install_PKG "$SALT_PKGS" \
    || Echo_Error "Failed to install $SALT_PKGS !!!"
  fi

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

  #[  -d /srv/salt ] && rm -rf /srv/salt
  
  cp -rp $PWD/install/salt /srv/
  
  cp -rp $PWD/install/pillar/top.sls /srv/pillar/top.sls

  Echo_Info "Salt-ssh test."
  salt-ssh "*" --priv=/etc/salt/pki/master/ssh/salt-ssh.rsa  test.ping -i > /dev/null && Echo_Ok
  salt-ssh "*" state.sls salt.setup --state-output=mixed

  Echo_Info "Waiting to start salt."
  for ((i=1;i<=60;i++ )); do
    echo -e -n "."
    sleep 1
    uuid=$(timeout 3 salt "*" grains.get uuid | grep '-' | awk '{print $1}')
    [ ! -z "$uuid" ] && (
      Write_Sls_File reg-uuid "$uuid" $MAIN_SLS
      Write_Host "$DEFAULT_LOCAL_IP" "$uuid"
    ) && break
  done
}

Init_Config_Func(){

    Write_Sls_File install-type "$INSTALL_TYPE"
    Echo_Info "Install Base Package ..."
    Install_Base_Pkg $1 && Echo_Ok

    Echo_Info "Init system config ..."
    Init_system && Echo_Ok

    Echo_Info "Init config ..."
    run && Echo_Ok

    # config salt
    Install_Salt && Echo_Ok
}

#================================ setup  =========================================


echo_banner "Rainbond v$RBD_VERSION"

check_func(){
    Echo_Info "Check func."
    System_Check
}

init_config(){
    if [ ! -f "$INIT_FILE" ];then
        Echo_Info "Init rainbond configure."
        Init_Config_Func && touch $INIT_FILE
    fi
}

install_func(){
    fail_num=0
    step_num=1
    all_steps=$(echo ${MANAGE_MODULES} | tr ' ' '\n' | wc -l)
    Echo_Info "will install manage node.It will take 15-30 minutes to install"
  
    for module in ${MANAGE_MODULES}
    do
        if [ "$module" = "image" ];then
            Echo_Info "Start install $module(step: $step_num/$all_steps), it will take 8-15 minutes "
            Echo_Info "This step will pull/load all docker images"
        else
            Echo_Info "Start install $module(step: $step_num/$all_steps) ..."
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
            REG_Status || return 0
        fi
        
        uuid=$(salt '*' grains.get uuid | grep "-" | awk '{print $1}')
        if [ -z "$uuid" ];then
            Echo_Error "Please check node status[uuid], Just Run systemctl status node"
            exit 1
        fi
        for ((i=1;i<=30;i++ ));do
            sleep 1
            notready=$(grctl node list | grep $uuid | grep offline)
            [ ! -z "$notready" ] && (
                grctl node up $uuid
            ) && break
        done
        Echo_Info "Install Rainbond successfully"
        public_ip=$(yq r /srv/pillar/rainbond.sls master-public-ip)
        private_ip=$(yq r /srv/pillar/rainbond.sls master-private-ip)
        for ((i=1;i<=60;i++ ));do
            sleep 1
            status_code=$(curl -s -I http://127.0.0.1:7070  | head -1 | awk '{print $2}')
            check_code=$(awk -v num1=$status_code -v num2=400 'BEGIN{print(num1<num2)?"0":"1"}')
            [ "$check_code" == "0" ] && (
                if [ ! -z "$public_ip" ];then
                    echo_banner "http://${public_ip}:7070"
                    echo "${public_ip}" > /opt/rainbond/envs/.exip
                else
                    echo_banner "http://${private_ip}:7070"
                    echo "${private_ip}" > /opt/rainbond/envs/.exip
                fi
            ) && break
        done
    else
        Echo_Info "install help"
        Echo_Info "https://www.rainbond.com/docs/stable/operation-manual/trouble-shooting/install-issue.html"
        exit 1
    fi
}

case $1 in
    *)
        check_func && init_config ${1:-"online"} && install_func ${@:2}
    ;;
esac
