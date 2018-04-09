node-script:
  file.managed:
    - source: salt://node/install/scripts/start.sh
    - name: {{ pillar['rbd-path'] }}/node/scripts/start.sh
    - makedirs: Ture
    - template: jinja
    - mode: 755
    - user: root
    - group: root

node-config-mapper.yaml:
  file.managed:
    - source: salt://node/install/config/mapper.yaml
    - name: {{ pillar['rbd-path'] }}/node/config/mapper.yml
    - makedirs: Ture
    - template: jinja

/etc/systemd/system/node.service:
  file.managed:
    - source: salt://node/install/systemd/node.service
    - template: jinja
    - user: root
    - group: root

node:
  service.running:
    - enable: True
    - reload: True
    - watch:
      - file: {{ pillar['rbd-path'] }}/node/scripts/start.sh