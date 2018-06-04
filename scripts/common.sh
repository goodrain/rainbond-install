#!/bin/bash

[[ $DEBUG ]] && set -x

# ================================Global ENV ================================

YQBIN="./scripts/yq"
MAIN_SLS="/srv/pillar/rainbond.sls"
RBD_VERSION=$(cat ./VERSION 2> /dev/null)
SALT_PKGS="salt-ssh"
RAINBOND_HOMEPAGE="https://www.rainbond.com"
PILLAR_DIR="./install/pillar"
RBD_DING="http://v2.reg.rbd.goodrain.org"
DOMAIN_API="http://domain.grapps.cn"
K8S_SERVICE=( kube-controller-manager kube-scheduler kube-apiserver kubelet)
RAINBOND_SERVICE=( etcd node calico )
MANAGE_MODULES="init \
storage \
docker \
misc \
grbase \
etcd \
network \
kubernetes.server \
node \
db \
plugins \
proxy \
prometheus \
kubernetes.node"

COMPUTE_MODULES="init \
storage \
docker \
misc \
etcd \
network \
node \
kubernetes.node"

# system common pkgs
SYS_COMMON_PKGS=( tar \
ntpdate \
wget \
curl \
tree \
lsof \
htop \
nload \
net-tools \
telnet \
rsync \
lvm2 \
pwgen \
git )

SYS_NAME=$(grep "^ID=" /etc/os-release | awk -F = '{print $2}'|sed 's/"//g')
SYS_VER=$(grep "^VERSION_ID=" /etc/os-release | awk -F = '{print $2}'|sed 's/"//g')

CPU_NUM=$(grep "processor" /proc/cpuinfo | wc -l )
CPU_LIMIT=2
MEM_SIZE=$(free -h | grep Mem | awk '{print $2}' | cut -d 'G' -f1 | awk -F '.' '{print $1}')
MEM_LIMIT=4

DEFAULT_LOCAL_IP="$(ip ad | grep 'inet ' | egrep ' 10.|172.|192.168' | awk '{print $2}' | cut -d '/' -f 1 | grep -v '172.30.42.1' | head -1)"
DEFAULT_PUBLIC_IP="$(ip ad | grep 'inet ' | egrep -v ' 10.|172.|192.168|127.' | awk '{print $2}' | cut -d '/' -f 1 | head -1)"
INIT_FILE="./.initialized"
OFFLINE_FILE="./.offlineprepared"

# redhat and centos
if [ "$SYS_NAME" == "centos" ];then
    INSTALL_BIN="yum"
    Cache_PKG="$INSTALL_BIN makecache fast -q"
    PKG_BIN="rpm -qi"
    SYS_BASE_PKGS=( perl \
    bind-utils \
    dstat iproute \
    epel-release \
    bash-completion )

    # centos salt repo
    #judgment below uses for offline env : do not install salt through internet ( changed by guox 2018.5.18 ).

    if [[ "$1" != "offline" ]];then
    cat > /etc/yum.repos.d/salt-repo.repo << END
[saltstack]
name=SaltStack archive/2017.7.5 Release Channel for RHEL/CentOS $releasever
baseurl=http://mirrors.ustc.edu.cn/salt/yum/redhat/7/\$basearch/archive/2017.7.5/
skip_if_unavailable=True
gpgcheck=0
enabled=1
enabled_metadata=1
END
    fi

# debian and ubuntu
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

    # debian salt repo
    cat > /etc/apt/sources.list.d/salt.list << END
deb http://mirrors.ustc.edu.cn/salt/apt/debian/9/amd64/2017.7 stretch main
END

fi

SALT_SSH_INSTALLED=$($PKG_BIN salt-ssh > /dev/null 2>&1 && echo 0)



#======================= Global Functions =============================

# Name   : Check service status
# Arges  : Service name
# Return : 0|!0 
Check_Service_State(){
    sname=$1
    systemctl  is-active $sname > /dev/null 2>&1
}

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
#          NAME:  Echo_Failed
#   DESCRIPTION:  Echo errors to stderr.
#----------------------------------------------------------------------------------------------------------------------
Echo_Failed() {
    printf >&2 "${TPUT_BGRED}${TPUT_WHITE}${TPUT_BOLD} FAILED ${TPUT_RESET} ${*} \n\n"
}

Echo_Error() {
    printf >&2 "${TPUT_BGRED}${TPUT_WHITE}${TPUT_BOLD} FAILED ${TPUT_RESET} ${*} \n\n"
    exit 1
}

Echo_EXIST() {
    printf >&2 "${TPUT_BGRED}${TPUT_WHITE}${TPUT_BOLD} EXIST ${TPUT_RESET} ${*} \n\n"
}

#---  FUNCTION  -------------------------------------------------------------------------------------------------------
#          NAME:  Echo_Info
#   DESCRIPTION:  Echo information to stdout.
#----------------------------------------------------------------------------------------------------------------------
Echo_Info() {
    echo >&2 " --- ${TPUT_DIM}${TPUT_BOLD}${*}${TPUT_RESET} --- "
}

#---  FUNCTION  -------------------------------------------------------------------------------------------------------
#          NAME:  Echo_Ok
#   DESCRIPTION:  Echo debug information to stdout.
#----------------------------------------------------------------------------------------------------------------------
Echo_Ok() {
   printf >&2 "${TPUT_BGGREEN}${TPUT_WHITE}${TPUT_BOLD} OK ${TPUT_RESET} ${*} \n\n"
}


Echo_Banner() {

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

REG_Status(){
    uid=$( Read_Sls_File reg-uuid $MAIN_SLS )
    iip=$( Read_Sls_File master-private-ip $MAIN_SLS )
    domain=$( Read_Sls_File domain $MAIN_SLS )
    if [[ "$domain" =~ "grapps" ]];then
        curl --connect-timeout 20 ${DOMAIN_API}/status\?uuid=$uid\&ip=$iip\&type=True\&domain=$domain
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

Install_PKG(){
    pkg_name="$@"
    $INSTALL_BIN install -y -q $pkg_name > /dev/null
}

# Name   : Write_Sls_File
# Args   : key,valume,(path)
Write_Sls_File(){
    key=$1
    value=$2
    slsfile=${3:-$MAIN_CONFIG}
    isExist=$( $YQBIN r $slsfile $key )
    if [ "$isExist" == "null" ];then
        $YQBIN w -i $slsfile $key "$value"
    fi
}

# Name   : Read_Sls_File
# Args   : key,valume,(path)
Read_Sls_File(){
    key=$1
    slsfile=${2:-$MAIN_CONFIG}
    $YQBIN r $slsfile $key
}

# Clear the job and data when  exit the program
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
            [ -d $rbdpath/data ] && rm -rf $rbdpath/data && Echo_Ok
        fi
    fi
    
}

# check python urllib3 for aliyun (CentOS 7.x)
Check_Python_Urllib(){
    if [ ! -f $INIT_FILE ];then
        if ( which pip > /dev/null 2>&1 );then
            if ( pip show urllib3 > /dev/null 2>&1 );then
                if [ "$SYS_NAME" == "centos" ];then
                    pip uninstall urllib3 -y  > /dev/null 2>&1 
                else
                    pip install -U urllib3 -y > /dev/null 2>&1
                fi
            fi
        fi
    fi
}
