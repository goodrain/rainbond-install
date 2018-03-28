base:
  "*":
    - deploy-salt
    - init
    - docker
    - etcd
    - storage
    - network
    - kubernetes
    - node

#  'role:compute':
#    - match: grains
#    - kubernetes.master
#    - init.init_manage
#  'role:manage':
#    - match: grains
#    - kubernetes.node
#   - init.init_compute
