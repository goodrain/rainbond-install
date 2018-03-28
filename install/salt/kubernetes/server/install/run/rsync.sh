#!/bin/bash

cp -a /grdata/kubernetes/kubecfg {{ pillar['rbd-path'] }}/kubernetes
cp -a /grdata/kubernetes/ssl {{ pillar['rbd-path'] }}/kubernetes

cp -a /grdata/kubernetes/kubecfg/* {{ pillar['rbd-path'] }}/k8s
cp -a /grdata/kubernetes/ssl {{ pillar['rbd-path'] }}/k8s