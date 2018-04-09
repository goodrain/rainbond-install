#!/bin/bash

{% if "manage" in grains['host'] %}
eval $(ssh-agent) > /dev/null
eval $(ssh-add) > /dev/null
NODE_OPTS="--log-level=debug --kube-conf={{ pillar['rbd-path'] }}/kubernetes/kubecfg/admin.kubeconfig  --statsd.mapping-config={{ pillar['rbd-path'] }}/node/config/mapper.yml --nodeid-file={{ pillar['rbd-path'] }}/etc/node/node_host_uuid.conf --static-task-path={{ pillar['rbd-path'] }}/node/tasks/ --etcd=http://127.0.0.1:2379   --hostIP={{ pillar['fqdn_ip4'] }} --run-mode master --noderule manage,compute"
{% else %}
NODE_OPTS="--log-level=debug --kube-conf={{ pillar['rbd-path'] }}/kubernetes/kubecfg/admin.kubeconfig --statsd.mapping-config={{ pillar['rbd-path'] }}/node/config/mapper.yml --nodeid-file={{ pillar['rbd-path'] }}/etc/node/node_host_uuid.conf --static-task-path={{ pillar['rbd-path'] }}/node/tasks/ --etcd=http://127.0.0.1:2379  --hostIP={{ grains['fqdn_ip4'] }}"
{% endif %}
exec /usr/local/bin/node $NODE_OPTS