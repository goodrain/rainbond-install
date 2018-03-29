etcd:
  server:
    image: rainbond/etcd:v3.2.13
    enabled: true
    bind:
      host: 192.168.199.28
    token: $(uuidgen)
    members:
    - host: 192.168.199.28
      name: manage01
      port: 2379
