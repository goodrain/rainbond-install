DEFAULT_IPV4={{ grains['fqdn_ip4'][0] }}
{% if "manage" in grains['host'] %}
ETCD_ENDPOINTS=http://127.0.0.1:2379
{% else %}
ETCD_ENDPOINTS=http://{{ pillar.etcd.server.bind.get('host', '127.0.0.1') }}:2379
{% endif %}
NODE_IMAGE={{ pillar.network.calico.get('image', 'rainbond/calico-node:v2.4.1') }}