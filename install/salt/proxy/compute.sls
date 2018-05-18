compute-runner-pull-image:
  cmd.run:
    - name: docker pull goodrain.me/runner

compute-adapter-pull-image:
  cmd.run:
    - name: docker pull goodrain.me/adapter

compute-pause-pull-image:
  cmd.run:
    - name: docker pull goodrain.me/pause-amd64:3.0

compute-tcm-pull-image:    
  cmd.run:
    - name: docker pull goodrain.me/tcm

compute-mesh-pull-image:    
  cmd.run:
    - name: docker pull goodrain.me/mesh_plugin