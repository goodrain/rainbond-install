#!/bin/bash

role=$1
if [[ "$role" =~ "master" ]];then
    bash /opt/rainbond/install/scripts/manage.sh ${@:2}
else
    bash /opt/rainbond/install/scripts/compute.sh ${@:2}
fi