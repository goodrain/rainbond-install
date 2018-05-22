{% set REGISTRYIMG = salt['pillar.get']('rainbond-modules:rbd-registry:image') -%}
{% set REGISTRYVER = salt['pillar.get']('rainbond-modules:rbd-registry:version') -%}

docker-pull-hub-image:
  cmd.run:
    - name: docker pull {{ REGISTRYIMG }}:{{ REGISTRYVER }}
    - unless: docker inspect {{ REGISTRYIMG }}:{{ REGISTRYVER }}

hub-upstart:
  cmd.run:
    - name: dc-compose up -d rbd-hub
    - unless: check_compose rbd-hub
    - require:
      - cmd: docker-pull-hub-image