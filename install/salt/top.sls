base:
  "*":
    - init
    - docker
    - etcd
    - storage
    - network
    - kubernetes.node
    - node
    - db
    - grbase
    - plugins
    - proxy
    - prometheus

  "role:manage":
    - match: grains
    - kubernetes.server
