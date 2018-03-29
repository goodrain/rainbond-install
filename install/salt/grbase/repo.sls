docker-pull-repo-image:
  cmd.run:
    - name: docker pull rainbond/rbd-repo:{{ pillar["rbd-version"] }}

repo-upstart:
  cmd.run:
    - name: dc-compose up -d rbd-repo
    - unless: docker images | grep rainbond/rbd-repo:{{ pillar["rbd-version"] }}