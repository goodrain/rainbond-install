etcd:
  server:
    image: rainbond/etcd:v3.2.13
    enabled: true
    bind:
      host: 172.16.0.169
    token: $(uuidgen)
    members:
    - host: 172.16.0.169
      name: manage01
      port: 2379
  proxy:
    image: rainbond/etcd:v3.2.13
    enabled: true