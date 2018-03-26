etcd:
  server:
    image: rainbond/etcd:v3.2.13
    enabled: true
    bind:
      host: 172.16.0.129
    token: $(uuidgen)
    members:
    - host: 172.16.0.129
      name: etcd01
      port: 2379