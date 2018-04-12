{% if "manage" in grains['id'] %}
docker-pull-dns-image:
  cmd.run:
    - name: docker pull rainbond/rbd-dns:{{ pillar["rbd-version"] }}
    - unless: docker inspect rainbond/rbd-dns:{{ pillar["rbd-version"] }}

dns-upstart:
  cmd.run:
    - name: dc-compose up -d rbd-dns
    - require:
      - cmd: docker-pull-dns-image
    - onchanges:
      - cmd: docker-pull-dns-image

{% endif %}

update-resolv:
  file.managed:
    - source: salt://grbase/file/resolv.conf
    - name: /etc/resolv.conf
    - backup: minion
    - template: jinja

{% if "manage" in grains['id'] %}

restart-docker:
  cmd.run:
    - name: systemctl restart docker
    - onchanges:
      - file: update-resolv
    - onlyif: dc-compose stop

<<<<<<< HEAD
dns-restart:
=======
{% if "manage" in grains['host'] %}

waiting_for_dns:
>>>>>>> 1f7ce53cddcd6fa644d38bd4eef0cc589a452030
  cmd.run:
    - name: checkdns lang.goodrain.me
    - retry:
        attempts: 20
        until: True
        interval: 3
        splay: 3

{% endif %}