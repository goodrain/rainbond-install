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

runner-pull-image:
  cmd.run:
    - name: docker pull rainbond/runner

runner-tag:
  cmd.run:
    - name: docker tag rainbond/runner goodrain.me/runner
  
runner-push-image:
  cmd.run:
    - name: docker push goodrain.me/runner

adapter-pull-image:
  cmd.run:
    - name: docker pull rainbond/adapter

adapter-tag:
  cmd.run:
    - name: docker tag rainbond/adapter goodrain.me/adapter

adapter-push-image:    
  cmd.run:
    - name: docker push goodrain.me/adapter

pause-pull-image:
  cmd.run:
    - name: docker pull rainbond/pause-amd64:3.0

pause-tag:
  cmd.run:
    - name: docker tag rainbond/pause-amd64:3.0 goodrain.me/pause-amd64:3.0
  
pause-push-image:
  cmd.run:
    - name: docker push goodrain.me/pause-amd64:3.0

builder-pull-image:
  cmd.run:
    - name: docker pull rainbond/builder

builder-tag:  
  cmd.run:
    - name: docker tag rainbond/builder goodrain.me/builder

builder-push-image:    
  cmd.run:
    - name: docker push goodrain.me/builder