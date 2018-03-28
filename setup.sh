#!/bin/bash

. scripts/common.sh

[ ! -d ./$LOG_DIR ] && mkdir ./$LOG_DIR
[ ! -f $INFO_FILE ] && touch $INFO_FILE

clear

# check system
opts=$@
mark=1
#循环十次

for i in $(seq 1 10)
do
    if [ ${#opts} -gt 1 ];then
        opt=$(echo $opts | awk -F '-' '{print$'$((i+1))'}')
        opt_key=$(echo $opt | awk '{prin $1}')
        opt_value=$(echo $opt | awk '{prin $2}')
            if [ "$opt_key" == "i" ];then
                opt_value=$(echo $opt | awk '{print $2}')
                /bin/bash  ./scripts/check.sh $opt_value 
            elif [ "$opt_key" == "f" ];then
                /bin/bash  ./scripts/check.sh force
            elif [ "$opt_key" == "h" ];then
                Echo_Info "Input -h to get this help"
                Echo_Info "Input -f to forced installation"
                Echo_Info "Input -i to specify the installation path"
            fi
    else
        /bin/bash  ./scripts/check.sh
        break
    fi
done


