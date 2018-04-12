docker-pull-repo-image:
  cmd.run:
    - name: docker pull rainbond/rbd-repo:{{ pillar["rbd-version"] }}
    - unless: docker inspect rainbond/rbd-repo:{{ pillar["rbd-version"] }}

repo-upstart:
  cmd.run:
    - name: dc-compose up -d rbd-repo
    - watch:
      - cmd: docker-pull-repo-image
    - require:
      - cmd: docker-pull-repo-image