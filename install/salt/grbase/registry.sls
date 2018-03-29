docker-pull-hub-image:
  cmd.run:
    - name: docker pull rainbond/rbd-registry:2.3.1

hub-upstart:
  cmd.run:
    - name: dc-compose up -d rbd-hub
    - unless: docker images | grep rainbond/rbd-registry:2.3.1