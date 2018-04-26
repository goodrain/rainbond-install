{% if "manage" in grains['id'] %}
docker-pull-dns-image:
  cmd.run:
    - name: docker pull rainbond/rbd-dns:{{ pillar["rbd-version"] }}
    - unless: docker inspect rainbond/rbd-dns:{{ pillar["rbd-version"] }}

dns-upstart:
  cmd.run:
    - name: dc-compose up -d rbd-dns
    - unless: check_compose rbd-dns
    - require:
      - cmd: docker-pull-dns-image

{% endif %}