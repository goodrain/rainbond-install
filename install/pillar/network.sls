network:
  calico:
    image: rainbond/calico-node:v2.4.1
    enabled: true
    net: 10.10.0.0/16
    