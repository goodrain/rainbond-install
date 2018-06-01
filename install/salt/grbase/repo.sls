{% set REPOIMG = salt['pillar.get']('rainbond-modules:rbd-repo:image') -%}
{% set REPOVER = salt['pillar.get']('rainbond-modules:rbd-repo:version') -%}
{% set PUBDOMAIN = salt['pillar.get']('public-image-domain') -%}
{% set PRIDOMAIN = salt['pillar.get']('private-image-domain') -%}

docker-pull-repo-image:
  cmd.run:
    - name: docker pull {{PUBDOMAIN}}/{{ REPOIMG }}:{{ REPOVER }}
    - unless: docker inspect {{PUBDOMAIN}}/{{ REPOIMG }}:{{ REPOVER }}

repo-upstart:
  cmd.run:
    - name: dc-compose up -d rbd-repo
    - unless: check_compose rbd-repo
    - require:
      - cmd: docker-pull-repo-image