base:
  "*":
    - deploy-salt
    - init
    - docker
    - etcd
    - storage
    - network
    - kubernetes.node
    - node

  "role:manage":
    - match: grains
    - kubernetes.server
    

#  'role:compute':
#    - match: grains
#    - kubernetes.master
#    - init.init_manage
#  'role:manage':
#    - match: grains
#    - kubernetes.node
#   - init.init_compute
