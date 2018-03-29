docker-pull-dns-image:
  cmd.run:
    - name: docker pull rainbond/rbd-dns:{{ pillar["rbd-version"] }}

dns-upstart:
  cmd.run:
    - name: dc-compose up -d rbd-dns
    - unless: docker images | grep rainbond/rbd-dns:{{ pillar["rbd-version"] }}

update-resolv:
  file.managed:
    - source: salt://grbase/file/resolv.conf
    - name: /etc/resolv.conf
    - backup: minion
    - template: jinja



