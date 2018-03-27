base:
  "*":
    - deploy-salt
    - docker
    - etcd
    - storage
    - network
    # - node
  'role:compute':
    - match: grains
    - init.init_manage
  'role:manage':
    - match: grains
    - init.init_compute
