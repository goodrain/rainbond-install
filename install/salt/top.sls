base:
  "*":
    - deploy-salt
    - docker
    - etcd
    - storage
    - network
    - node
  #  - kubernetes.master
  'role:compute':
    - match: grains
    - init.init_manage
    - kubernetes.master
  'role:manage':
    - match: grains
    - init.init_compute
    - kubernetes.node
