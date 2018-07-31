node-uuid-conf:
  file.managed:
    - source: salt://install/files/node/node_host_uuid.conf
    - name: {{ pillar['rbd-path'] }}/etc/rbd-node/node_host_uuid.conf
    - makedirs: True
    - template: jinja

node-script:
  file.managed:
    - source: salt://install/files/node/start-node.sh
    - name: {{ pillar['rbd-path'] }}/scripts/start-node.sh
    - makedirs: True
    - template: jinja
    - mode: 755
    - user: root
    - group: root

/etc/systemd/system/node.service:
  file.managed:
    - source: salt://install/files/node/node.service
    - template: jinja
    - user: root
    - group: root

/usr/local/bin/node:
  file.managed:
    - source: salt://install/files/misc/bin/node
    - mode: 777
    - user: root
    - group: root

node:
  service.running:
    - enable: True
    - watch:
      - file: node-uuid-conf
      - file: node-script
  cmd.run:
    - name: systemctl restart node