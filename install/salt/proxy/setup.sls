docker-pull-proxy-image:
  cmd.run:
    - name: docker pull rainbond/rbd-proxy:{{ pillar['rbd-version'] }}

proxy-upstart:
  cmd.run:
    - name: dc-compose up -d rbd-proxy
    - unless: docker images | grep rainbond/rbd-proxy:{{ pillar['rbd-version'] }}

docker-plugins:
  cmd.run:
    - name: docker pull rainbond/plugins:tcm;docker tag rainbond/plugins:tcm goodrain.me/tcm;docker push goodrain.me/tcm
    - unless: docker pull goodrain.me/tcm