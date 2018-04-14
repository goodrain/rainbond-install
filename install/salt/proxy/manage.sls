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

reload-proxy:
  cmd.run:
    - name: docker exec rbd-proxy nginx -s reload
    - onlyif: docker exec rbd-proxy nginx -t
    - onchanges:
      - file: maven-site
      - file: lang-site
      - file: console

runner-pull-image:
  cmd.run:
    - name: docker pull rainbond/runner
    - unless: docker inspect rainbond/runner

runner-tag:
  cmd.run:
    - name: docker tag rainbond/runner goodrain.me/runner
    - unless: docker inspect goodrain.me/runner
    - require:
      - cmd: runner-pull-image
  
runner-push-image:
  cmd.run:
    - name: docker push goodrain.me/runner
    - require:
      - cmd: runner-tag

adapter-pull-image:
  cmd.run:
    - name: docker pull rainbond/adapter
    - unless: docker inspect rainbond/adapter

adapter-tag:
  cmd.run:
    - name: docker tag rainbond/adapter goodrain.me/adapter
    - unless: docker inspect goodrain.me/adapter
    - require:
      - cmd: adapter-pull-image

adapter-push-image:    
  cmd.run:
    - name: docker push goodrain.me/adapter
    - require:
      - cmd: adapter-tag

pause-pull-image:
  cmd.run:
    - name: docker pull rainbond/pause-amd64:3.0
    - unless: docker inspect rainbond/pause-amd64:3.0

pause-tag:
  cmd.run:
    - name: docker tag rainbond/pause-amd64:3.0 goodrain.me/pause-amd64:3.0
    - unless: docker inspect goodrain.me/pause-amd64:3.0
    - require:
      - cmd: pause-pull-image
  
pause-push-image:
  cmd.run:
    - name: docker push goodrain.me/pause-amd64:3.0
    - require:
      - cmd: pause-tag

builder-pull-image:
  cmd.run:
    - name: docker pull rainbond/builder
    - unless: docker inspect rainbond/builder

builder-tag:  
  cmd.run:
    - name: docker tag rainbond/builder goodrain.me/builder
    - unless: docker inspect goodrain.me/builder
    - require:
      - cmd: builder-pull-image

builder-push-image:    
  cmd.run:
    - name: docker push goodrain.me/builder
    - require:
      - cmd: builder-tag