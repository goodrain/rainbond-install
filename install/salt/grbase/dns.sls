{% if "manage" in grains['id'] %}
{% set DNSIMG = salt['pillar.get']('rainbond-modules:rbd-dns:image') -%}
{% set DNSVER = salt['pillar.get']('rainbond-modules:rbd-dns:version') -%}
{% set PUBDOMAIN = salt['pillar.get']('public-image-domain') -%}
{% set PRIDOMAIN = salt['pillar.get']('private-image-domain') -%}

docker-pull-dns-image:
  cmd.run:
{% if pillar['install-type']!="offline" %}
    - name: docker pull {{PUBDOMAIN}}/{{ DNSIMG }}:{{ DNSVER }}
{% else %}
    - name: docker load -i {{ pillar['install-script-path'] }}/install/imgs/{{PUBDOMAIN}}_{{ DNSIMG }}_{{ DNSVER }}.gz
{% endif %}
    - unless: docker inspect {{PUBDOMAIN}}/{{ DNSIMG }}:{{ DNSVER }}

dns-upstart:
  cmd.run:
    - name: dc-compose up -d rbd-dns
    - unless: check_compose rbd-dns
    - require:
      - cmd: docker-pull-dns-image

{% endif %}