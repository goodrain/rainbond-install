base:
  "*":
    - deploy-salt
    - docker
    - etcd
  'node_type:tree':
    - match: grain
    - init.init_tree
  'node_type:rain':
    - match: grain
    - init.init_rain
