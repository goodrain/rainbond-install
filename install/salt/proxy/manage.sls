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
  cmd.run:
    - name: docker pull rainbond/runner; docker tag rainbond/runner goodrain.me/runner;docker push goodrain.me/runner
    - unless: docker pull goodrain.me/runner

adapter-pull:
    cmd.run:
    - name: docker pull rainbond/adapter; docker tag rainbond/adapter goodrain.me/adapter;docker push goodrain.me/adapter
    - unless: docker pull goodrain.me/adapter

pause-pull:
    cmd.run:
    - name: docker pull rainbond/pause-amd64:3.0; docker tag rainbond/pause-amd64:3.0 goodrain.me/pause-amd64:3.0;docker push goodrain.me/pause-amd64:3.0
    - unless: docker pull goodrain.me/pause-amd64:3.0

builder-pull:
    cmd.run:
    - name: docker pull rainbond/builder; docker tag rainbond/builder goodrain.me/builder;docker push goodrain.me/builder
    - unless: docker pull goodrain.me/builder