compute-runner-pull-image:
  cmd.run:
    - name: docker push goodrain.me/runner
    - unless: docker inspect goodrain.me/runner

compute-adapter-pull-image:
  cmd.run:
    - name: docker pull goodrain.me/adapter
    - unless: docker inspect goodrain.me/adapter

compute-pause-pull-image:
  cmd.run:
    - name: docker pull goodrain.me/pause-amd64:3.0
    - unless: docker inspect goodrain.me/pause-amd64:3.0

compute-tcm-pull-image:    
  cmd.run:
    - name: docker pull goodrain.me/tcm
    - unless: docker inspect goodrain.me/tcm