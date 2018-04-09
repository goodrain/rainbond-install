HOST_UUID={{ grains['uuid'] }}
DNS_SERVERS={{ pillar['inet-ip'] }}
HOST_IP={{ grains['fqdn_ip4'] }}
REG="false"