base:
  "*":
    - deploy-salt
    - docker
  'node_type:tree':
    - match: grain
    - init.init_tree
  'node_type:rain':
    - match: grain
    - init.init_rain
