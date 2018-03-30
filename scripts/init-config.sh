#!/bin/bash
                     # Treat unset variables as an error
# make sure we have a UID
[ -z "${UID}" ] && UID="$(id -u)"

# get the project's current path
PATH="$(pwd)"

# make sure we have DEFAULT_LOCAL_IP

# check pillar dir
[ ! -d "$PATH/install/pillar" ] && mkdir -p "$PATH/install/pillar"

# -----------------------------------------------------------------------------
# checking the availability of commands

which_cmd() {
    which "${1}" 2>/dev/null || \
        command -v "${1}" 2>/dev/null
}

check_cmd() {
    which_cmd "${1}" >/dev/null 2>&1 && return 0
    return 1
}




run(){
    db_init
    etcd
    kubernetes
    calico
    plugins
    write_top
}

case $1 in
    *)
    run
    ;;
esac