#!/bin/bash

#curl https://pkg.rainbond.com/releases/common/yq -o ./yq

docker build -t rainbond/pkg-download:ubuntu-1604-v2 .

#rm -rf ./yq