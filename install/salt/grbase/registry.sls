docker-pull-hub-image:
  cmd.run:
    - name: docker pull rainbond/rbd-registry:2.3.1
    - unless: docker inspect rainbond/rbd-registry:2.3.1

hub-upstart:
  cmd.run:
    - name: dc-compose up -d rbd-hub
    - watch:
      - cmd: docker-pull-hub-image
    - require:
      - cmd: docker-pull-hub-image