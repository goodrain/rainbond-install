{% set REGISTRYIMG = salt['pillar.get']('rainbond-modules:rbd-registry:image') -%}
{% set REGISTRYVER = salt['pillar.get']('rainbond-modules:rbd-registry:version') -%}
{% set PUBDOMAIN = salt['pillar.get']('public-image-domain') -%}
{% set PRIDOMAIN = salt['pillar.get']('private-image-domain') -%}

docker-pull-hub-image:
  cmd.run:
    - name: docker pull {{PUBDOMAIN}}/{{ REGISTRYIMG }}:{{ REGISTRYVER }}
    - unless: docker inspect {{PUBDOMAIN}}/{{ REGISTRYIMG }}:{{ REGISTRYVER }}

hub-upstart:
  cmd.run:
    - name: dc-compose up -d rbd-hub
    - unless: check_compose rbd-hub
    - require:
      - cmd: docker-pull-hub-image