#!/bin/bash

secretkey=$(yq r /srv/pillar/rainbond.sls secretkey)

curl http://127.0.0.1:7999/login -H "Accept: application/x-yaml" -d username='saltapi' -d password=$secretkey -d eauth='pam' > /tmp/.token