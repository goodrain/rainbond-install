{% if "manage" in grains['id'] %}
{% set DNSIMG = salt['pillar.get']('rainbond-modules:rbd-dns:image') -%}
{% set DNSVER = salt['pillar.get']('rainbond-modules:rbd-dns:version') -%}
docker-pull-dns-image:
  cmd.run:
    - name: docker pull {{ DNSIMG }}:{{ DNSVER }}
    - unless: docker inspect {{ DNSIMG }}:{{ DNSVER }}

dns-upstart:
  cmd.run:
    - name: dc-compose up -d rbd-dns
    - unless: check_compose rbd-dns
    - require:
      - cmd: docker-pull-dns-image

{% endif %}