#!/bin/bash

#curl https://pkg.rainbond.com/releases/common/yq -o ./yq

docker build -t rainbond/pkg-download:centos-1708-v2 .

#rm -rf ./yq