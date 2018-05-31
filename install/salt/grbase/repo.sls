{% set REPOIMG = salt['pillar.get']('rainbond-modules:rbd-repo:image') -%}
{% set REPOVER = salt['pillar.get']('rainbond-modules:rbd-repo:version') -%}

docker-pull-repo-image:
  cmd.run:
    - name: docker pull {{ REPOIMG }}:{{ REPOVER }}
    - unless: docker inspect {{ REPOIMG }}:{{ REPOVER }}

repo-upstart:
  cmd.run:
    - name: dc-compose up -d rbd-repo
    - unless: check_compose rbd-repo
    - require:
      - cmd: docker-pull-repo-image