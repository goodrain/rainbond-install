{% if pillar.etcd.proxy.enabled %}

pull-etcd-proxy-image:
  cmd.run:
    - name: docker pull {{ server.get('image', 'rainbond/etcd:v3.2.13') }}

etcd-proxy-env:
  file.managed:
    - source: salt://etcd/install/envs/petcd.sh
    - name: {{ pillar['rbd-path'] }}/etc/envs/petcd.sh
    - template: jinja
    - makedirs: Ture
    - mode: 644
    - user: root
    - group: root

etcd-proxy-script:
  file.managed:
    - source: salt://etcd/install/scripts/start-proxy.sh
    - name: {{ pillar['rbd-path'] }}/petcd/scripts/start.sh
    - makedirs: Ture
    - template: jinja
    - mode: 755
    - user: root
    - group: root

/etc/systemd/system/etcd-proxy.service:
  file.managed:
    - source: salt://etcd/install/systemd/etcd-proxy.service
    - template: jinja
    - user: root
    - group: root

etcd-proxy:
  service.running:
    - enable: True
    - reload: True
    - watch:
      - file: {{ pillar['rbd-path'] }}/petcd/scripts/start.sh
      - file: {{ pillar['rbd-path'] }}/etc/envs/petcd.sh
      - cmd: pull-etcd-proxy-image

{% endif %}