{%- from "etcd/map.jinja" import server with context %}
{%- if server.enabled %}

#pull-image:
#  docker.pulled:
#    - name: {{ server.get('image', 'rainbond/etcd:v3.2.13') }}

pull-etcd-image:
  cmd.run:
    - name: docker pull {{ server.get('image', 'rainbond/etcd:v3.2.13') }}

etcd-env:
  file.managed:
    - source: salt://etcd/install/envs/etcd.sh
    - name: {{ pillar['rbd-path'] }}/etc/envs/etcd.sh
    - template: jinja
    - makedirs: Ture
    - mode: 644
    - user: root
    - group: root

etcd-script:
  file.managed:
    - source: salt://etcd/install/scripts/start.sh
    - name: {{ pillar['rbd-path'] }}/etcd/scripts/start.sh
    - makedirs: Ture
    - template: jinja
    - mode: 755
    - user: root
    - group: root

#/usr/local/bin/etcdctl:
#  file.managed:
#    - source: salt://etcd/install/systemd/etcd.service
#    - mode: 755
#    - makedirs: Ture



/etc/systemd/system/etcd.service:
  file.managed:
    - source: salt://etcd/install/systemd/etcd.service
    - template: jinja
    - user: root
    - group: root

etcd:
  service.running:
    - enable: True
    - reload: True
    - watch:
      - file: {{ pillar['rbd-path'] }}/etcd/scripts/start.sh
      - file: {{ pillar['rbd-path'] }}/etc/envs/etcd.sh
      - cmd: pull-image

{% endif %}

