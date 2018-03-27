DEFAULT_IPV4= {{ pillar.network.calico.get('bind', '172.16.0.129') }}
ETCD_ENDPOINTS=http://{{ pillar.etcd.server.bind.get('host', '127.0.0.1') }}:2379
NODE_IMAGE={{ pillar.network.calico.get('image', 'rainbond/calico-node:v2.4.1') }}