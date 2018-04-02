maven-site:
  file.managed:
    - source: salt://proxy/site/maven
    - name: {{ pillar['rbd-path'] }}/proxy/sites/maven
    - template: jinja
    - makedirs: Ture

lang-site:
  file.managed:
    - source: salt://proxy/site/lang
    - name: {{ pillar['rbd-path'] }}/proxy/sites/lang
    - template: jinja
    - makedirs: Ture

console:
  file.managed:
    - source: salt://proxy/site/console
    - name: {{ pillar['rbd-path'] }}/proxy/sites/console
    - template: jinja
    - makedirs: Ture

registry:
  file.managed:
    - source: salt://proxy/site/registry
    - name: {{ pillar['rbd-path'] }}/proxy/sites/registry
    - template: jinja
    - makedirs: Ture

ssl-config:
  file.recurse:
    - source: salt://proxy/ssl/goodrain.me
    - name: {{ pillar['rbd-path'] }}/proxy/ssl/goodrain.me
    - makedirs: Ture

runner-pull:
  docker.pulled:
    - name: rainbond/runner
  cmd.run:
    - name: docker tag rainbond/runner goodrain.me/runner
  docker.pushed:
    - name: goodrain.me/runner

adapter-pull:
    docker.pulled:
      - name: rainbond/adapter
    cmd.run:
      - name: docker tag rainbond/adapter goodrain.me/adapter
    docker.pushed:
      - name: docker push goodrain.me/adapter

pause-pull:
    docker.pulled:
      - name: rainbond/pause-amd64
      - tag: 3.0
    cmd.run:
      - name: docker tag rainbond/pause-amd64:3.0 goodrain.me/pause-amd64:3.0
    docker.pushed:
      - name: goodrain.me/pause-amd64
      - tag: 3.0

builder-pull:
    docker.pulled:
      - name: rainbond/builder
    cmd.run:
      - name: docker tag rainbond/builder goodrain.me/builder
    docker.pushed:
      - name: oodrain.me/builder