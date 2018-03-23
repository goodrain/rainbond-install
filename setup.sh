#!/bin/bash

. scripts/common.sh

[ ! -d ./$LOG_DIR ] && mkdir ./$LOG_DIR

clear

# check system
/bin/bash  ./scripts/check.sh
