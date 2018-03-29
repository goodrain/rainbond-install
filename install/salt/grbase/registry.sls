docker-pull-hub-image:
  cmd.run:
    - name: docker pull rainbond/rbd-hub:{{ pillar["rbd-version"] }}

hub-upstart:
  cmd.run:
    - name: dc-compose up -d rbd-hub
    - unless: docker images | grep rainbond/rbd-hub:{{ pillar["rbd-version"] }}