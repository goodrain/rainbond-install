base:
  "*":
    - init
    - docker
    - misc
    - etcd
    - storage
    - network
    - kubernetes.node
    - node
    - db
    - grbase
    - plugins
    - proxy

  "role:manage":
    - match: grains
    - kubernetes.server
