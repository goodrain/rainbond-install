DEFAULT_IPV4={{ grains['fqdn_ip4'][0] }}
{% if "manage" in grains['id'] %}
ETCD_ENDPOINTS=http://127.0.0.1:2379
{% else %}
ETCD_ENDPOINTS=http://{{ pillar.etcd.server.bind.get('host', '127.0.0.1') }}:2379
{% endif %}
NODE_IMAGE={{ pillar['rainbond-modules']['rbd-dns']['image'] }}:{{ pillar['rainbond-modules']['rbd-dns']['version'] }}