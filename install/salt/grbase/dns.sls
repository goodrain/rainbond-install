{% if "manage" in grains['host'] %}
docker-pull-dns-image:
  cmd.run:
    - name: docker pull rainbond/rbd-dns:{{ pillar["rbd-version"] }}

dns-upstart:
  cmd.run:
    - name: dc-compose up -d rbd-dns
    - unless: docker images | grep rainbond/rbd-dns:{{ pillar["rbd-version"] }}

{% endif %}

update-resolv:
  file.managed:
    - source: salt://grbase/file/resolv.conf
    - name: /etc/resolv.conf
    - backup: minion
    - template: jinja

restart-docker:
  cmd.run:
    - name: systemctl restart docker
    - onlyif: dc-compose stop

{% if "manage" in grains['host'] %}

dns-restart:
  cmd.run:
    - name: dc-compose up -d rbd-dns
    - unless: dps | grep rbd-dns
    - require:
      - cmd: restart-docker

{% endif %}




