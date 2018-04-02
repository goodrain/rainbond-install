#!/bin/bash

{% if "manage" in grains['host'] %}
eval $(ssh-agent) > /dev/null
eval $(ssh-add) > /dev/null
NODE_OPTS="--log-level=debug --kube-conf={{ pillar['rbd-path'] }}/kubernetes/kubecfg/admin.kubeconfig  --statsd.mapping-config={{ pillar['rbd-path'] }}/node/config/mapper.yml --static-task-path=/node/tasks/ --etcd=http://127.0.0.1:2379   --hostIP={{ pillar['inet-ip'] }} --run-mode master --noderule manage,compute"
{% else %}
NODE_OPTS="--log-level=debug --kube-conf={{ pillar['rbd-path'] }}/kubernetes/kubecfg/admin.kubeconfig --statsd.mapping-config={{ pillar['rbd-path'] }}/node/config/mapper.yml --static-task-path=/node/tasks/ --etcd=http://127.0.0.1:2379  --hostIP={{ pillar['inet-ip'] }}"
{% endif %}
exec /usr/local/bin/node $NODE_OPTS