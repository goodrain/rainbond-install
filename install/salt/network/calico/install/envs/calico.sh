DEFAULT_IPV4={{ grains['mip'][0] }}
{% if "manage" in grains['id'] %}
ETCD_ENDPOINTS=http://127.0.0.1:2379
{% else %}
ETCD_ENDPOINTS=http://{{ pillar.etcd.server.bind.get('host', '127.0.0.1') }}:2379
{% endif %}
NODE_IMAGE={{ pillar['private-image-domain'] }}/{{ pillar['network']['calico']['image'] }}:{{ pillar['network']['calico']['version'] }}