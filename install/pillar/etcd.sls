etcd:
  server:
    image: rainbond/etcd:v3.2.13
    enabled: true
    bind:
      host: 10.211.55.4
    token: 2a583882-0b61-41aa-808d-e36751e01c59
    members:
    - host: 10.211.55.4
      name: manage01
      port: 2379
  proxy:
    image: rainbond/etcd:v3.2.13
    enabled: true
