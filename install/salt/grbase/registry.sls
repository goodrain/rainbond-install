docker-pull-hub-image:
  cmd.run:
    - name: docker pull rainbond/rbd-registry:2.3.1
    - require:
      - cmd: waiting_for_dns
    - unless: docker inspect rainbond/rbd-registry:2.3.1

hub-upstart:
  cmd.run:
    - name: dc-compose up -d rbd-hub
    - onchanges:
      - cmd: docker-pull-hub-image
    - require:
      - cmd: docker-pull-hub-image