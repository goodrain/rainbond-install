#!/bin/bash

mkdir -p {{ pillar['rbd-path'] }}/kubernetes/{kubecfg,ssl}/

cp -a /grdata/kubernetes/kubecfg/* {{ pillar['rbd-path'] }}/kubernetes/kubecfg/
cp -a /grdata/kubernetes/ssl/* {{ pillar['rbd-path'] }}/kubernetes/ssl/

mkdir -p {{ pillar['rbd-path'] }}/k8s/ssl

cp -a /grdata/kubernetes/kubecfg/* {{ pillar['rbd-path'] }}/k8s
cp -a /grdata/kubernetes/ssl/* {{ pillar['rbd-path'] }}/k8s/ssl