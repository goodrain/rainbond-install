network:
  calico:
    image: rainbond/calico-node:v2.4.1
    enabled: true
    bind: 172.16.0.169
    net: 10.10.0.0/16
    