kube-site:
  file.managed:
    - source: salt://proxy/site/kube
    - name: {{ pillar['rbd-path'] }}/proxy/sites/kube
    - template: jinja
    - makedirs: Ture

compute-reload-proxy:
  cmd.run:
    - name: docker exec rbd-proxy nginx -s reload
    - onchanges:
      - file: kube-site
  
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