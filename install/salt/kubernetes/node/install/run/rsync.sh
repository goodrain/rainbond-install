#!/bin/bash

[ ! -d "{{ pillar['rbd-path'] }}/kubernetes/kubecfg" ] && (
    cp -a /grdata/kubernetes/kubecfg {{ pillar['rbd-path'] }}/kubernetes
)

[ ! -d "{{ pillar['rbd-path'] }}/kubernetes/ssl" ] && (
    cp -a /grdata/kubernetes/ssl {{ pillar['rbd-path'] }}/kubernetes
)

echo ""