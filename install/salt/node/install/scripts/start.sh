#!/bin/sh

{% if pillar['role'] |lower == 'manage' %}
    eval $(ssh-agent) > /dev/null
    eval $(ssh-add) > /dev/null
    NODE_OPTS="--log-level=debug --statsd.mapping-config={{ pillar['rbd-path'] }}/node/config/mapper.yml --static-task-path=/node/tasks/ --etcd=http://127.0.0.1:2379  --kube-conf={{ pillar['rbd-path'] }}/kubernetes/admin.kubeconfig --hostIP={{ pillar['inet-ip'] }} --run-mode master --noderule manage"
{% else %}
    NODE_OPTS="--log-level=debug --statsd.mapping-config={{ pillar['rbd-path'] }}/node/config/mapper.yml --static-task-path=/node/tasks/ --etcd=http://127.0.0.1:2379 --kube-conf={{ pillar['rbd-path'] }}/kubernetes/admin.kubeconfig --hostIP={{ pillar['inet-ip'] }}"
{% endif %}
exec /usr/local/bin/rainbond-node $ACP_NODE_OPTS