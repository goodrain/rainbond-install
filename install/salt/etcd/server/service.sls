{% if pillar.etcd.server.enabled %}

pull-etcd-image:
  cmd.run:
    - name: docker pull {{ pillar.etcd.server.get('image', 'rainbond/etcd:v3.2.13') }}
    - unless: docker inspect {{ pillar.etcd.server.get('image', 'rainbond/etcd:v3.2.13') }}

etcd-tag:
  cmd.run:
    - name: docker tag rainbond/etcd:v3.2.13 goodrain.me/etcd:v3.2.13
    - unless: docker inspect goodrain.me/etcd:v3.2.13
    - require:
      - cmd: pull-etcd-image

etcd-env:
  file.managed:
    - source: salt://etcd/install/envs/etcd.sh
    - name: {{ pillar['rbd-path'] }}/envs/etcd.sh
    - template: jinja
    - makedirs: Ture
    - mode: 644
    - user: root
    - group: root

etcd-script:
  file.managed:
    - source: salt://etcd/install/scripts/start-etcd.sh
    - name: {{ pillar['rbd-path'] }}/scripts/start-etcd.sh
    - makedirs: Ture
    - template: jinja
    - mode: 755
    - user: root
    - group: root

/etc/systemd/system/etcd.service:
  file.managed:
    - source: salt://etcd/install/systemd/etcd.service
    - template: jinja
    - user: root
    - group: root

etcd:
  service.running:
    - enable: True
    - watch:
      - file: etcd-script
      - file: etcd-env
      - cmd: pull-etcd-image
    - require:
      - file: /etc/systemd/system/etcd.service
      - file: etcd-script
      - file: etcd-env
      - cmd: pull-etcd-image
  

{% endif %}

