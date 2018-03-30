#!/bin/bash

. scripts/common.sh

[ ! -d ./$LOG_DIR ] && mkdir ./$LOG_DIR
[ ! -d $PILLAR_DIR ] && mkdir $PILLAR_DIR || rm $PILLAR_DIR/* -rf
[ ! -f $PILLAR_DIR/system_info.sls ] && touch $PILLAR_DIR/system_info.sls

clear

while getopts "i:fh" arg #选项后面的冒号表示该选项需要参数
do
    case $arg in
    i)
        export RBD_PATH="$OPTARG" #参数存在$OPTARG中
        ;;
    f)
        export IS_FORCE="true"
        ;;
    r)
        export RBD_ROLE="$OPTARG"
        ;;
    h)
        Echo_Info "-f,          Ignore the hardware limit, Force install"
        Echo_Info "-i [PATH],   Specify a installation path"
        exit 0
        ;;
    ?) #未识别的arg
        echo "unkonw argument"
        exit 1
        ;;
    esac
done

/bin/bash ./scripts/check.sh
/bin/bash ./scripts/init-config.sh