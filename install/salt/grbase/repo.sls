docker-pull-repo-image:
  cmd.run:
    - name: docker pull rainbond/rbd-repo:{{ pillar["rbd-version"] }}
    - require:
      - cmd: waiting_for_dns
    - unless: docker inspect rainbond/rbd-repo:{{ pillar["rbd-version"] }}

repo-upstart:
  cmd.run:
    - name: dc-compose up -d rbd-repo
    - onchanges:
      - cmd: docker-pull-repo-image
    - require:
      - cmd: docker-pull-repo-image