HOST_UUID={{ grains['uuid'] }}
DNS_SERVERS={{ pillar['master-ip'] }}
HOST_IP={{ grains['fqdn_ip4'][0] }}
REG="false"