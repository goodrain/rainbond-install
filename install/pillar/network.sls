network:
  calico:
    image: rainbond/calico-node:v2.4.1
    enabled: true
    bind: 192.168.199.28
    net: 10.10.0.0/16
    
