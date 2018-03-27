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
            elif [ "$opt_key" == "h" ];then
                /bin/bash  ./scripts/check.sh force
            fi
    else
        /bin/bash  ./scripts/check.sh
        break
    fi
done


# for i in $(seq 1 10)
# do
# opt=$(echo $opts | awk '{print ($'$mark',$'$((mark+1))')}')
# opt_key=$(echo $opt | awk '{prin $1}')
# opt_value=$(echo $opt | awk '{prin $2}')
# case $opt_key in
#     -f) /bin/bash  ./scripts/check.sh force ;;
#     -i) /bin/bash  ./scripts/check.sh $opt_value ;;
# esac

# mark=$((mark+2))
# echo $mark
# done

