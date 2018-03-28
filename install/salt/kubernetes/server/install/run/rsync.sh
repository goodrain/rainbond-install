#!/bin/bash

cp -a /grdata/kubernetes/kubecfg {{ pillar['rbd-path'] }}/kubernetes
cp -a /grdata/kubernetes/ssl {{ pillar['rbd-path'] }}/kubernetes