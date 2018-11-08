#!/bin/bash

{% if "manage" in grains['id'] %}
{% if grains['node_role'][0] == "worker" %}
NODE_OPTS="--log-level=warn  --kube-conf={{ pillar['rbd-path'] }}/etc/kubernetes/kubecfg/admin.kubeconfig --nodeid-file={{ pillar['rbd-path'] }}/etc/rbd-node/node_host_uuid.conf --static-task-path={{ pillar['rbd-path'] }}/etc/rbd-node/tasks/ --etcd=http://127.0.0.1:2379   --hostIP={{ grains['mip'][0] }} --service-list-file={{ pillar['rbd-path'] }}/conf/master.yaml --run-mode master --noderule manage,compute"
{% else %}
NODE_OPTS="--log-level=warn --kube-conf={{ pillar['rbd-path'] }}/etc/kubernetes/kubecfg/admin.kubeconfig --nodeid-file={{ pillar['rbd-path'] }}/etc/rbd-node/node_host_uuid.conf --static-task-path={{ pillar['rbd-path'] }}/etc/rbd-node/tasks/ --etcd=http://127.0.0.1:2379   --hostIP={{ grains['mip'][0] }} --service-list-file={{ pillar['rbd-path'] }}/conf/master.yaml --run-mode master --noderule manage"
{% endif %}
{% else %}
NODE_OPTS="--log-level=warn --kube-conf={{ pillar['rbd-path'] }}/etc/kubernetes/kubecfg/admin.kubeconfig --nodeid-file={{ pillar['rbd-path'] }}/etc/rbd-node/node_host_uuid.conf --static-task-path={{ pillar['rbd-path'] }}/etc/rbd-node/tasks/ --etcd=http://127.0.0.1:2379  --hostIP={{ grains['mip'][0] }} --service-list-file={{ pillar['rbd-path'] }}/conf/worker.yaml"
{% endif %}
exec /usr/local/bin/node $NODE_OPTS
