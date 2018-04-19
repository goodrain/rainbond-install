docker-pull-plugins:
  cmd.run:
    - name: docker pull rainbond/plugins:tcm
    - unless: docker inspect rainbond/plugins:tcm
    
plugins-tag:
  cmd.run:
    - name: docker tag rainbond/plugins:tcm goodrain.me/tcm
    - unless: docker inspect goodrain.me/tcm
    - require:
      - cmd: docker-pull-plugins

plugins-push:
  cmd.run:
    - name: docker push goodrain.me/tcm
    - require:
      - cmd: plugins-tag