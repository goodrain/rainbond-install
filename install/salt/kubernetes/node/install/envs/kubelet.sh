HOST_UUID={{ grains['uuid'] }}
DNS_SERVERS={{ pillar['master-private-ip'] }}
HOST_IP={{ grains['mip'] }}
REG="false"