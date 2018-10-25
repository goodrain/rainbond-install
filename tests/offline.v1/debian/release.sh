#!/bin/bash

curl https://pkg.rainbond.com/releases/common/yq -o ./yq

docker build -t rainbond/pkg-download:debian-95 .

rm -rf ./yq