#!/bin/bash

exec /usr/bin/docker run --net=host \
--privileged \
--name=calico  \
--restart=always \
-e NO_DEFAULT_POOLS= \
-e CALICO_LIBNETWORK_ENABLED=true \
-e IP=${DEFAULT_IPV4} \
-e CALICO_LIBNETWORK_CREATE_PROFILES=true \
-e CALICO_LIBNETWORK_LABEL_ENDPOINTS=false \
-e CALICO_LIBNETWORK_IFPREFIX=cali \
-e NODENAME=${HOSTNAME} \
-e CALICO_NETWORKING_BACKEND=bird \
-e IP6_AUTODETECTION_METHOD=first-found \
-e ETCD_ENDPOINTS=${ETCD_ENDPOINTS} \
-v /var/log/calico:/var/log/calico \
-v /var/run/calico:/var/run/calico \
-v /lib/modules:/lib/modules \
-v /run/docker/plugins:/run/docker/plugins \
-v /var/run/docker.sock:/var/run/docker.sock \
${NODE_IMAGE}