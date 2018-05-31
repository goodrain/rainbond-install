node-script:
  file.managed:
    - source: salt://node/install/scripts/start-node.sh
    - name: {{ pillar['rbd-path'] }}/scripts/start-node.sh
    - makedirs: True
    - template: jinja
    - mode: 755
    - user: root
    - group: root

node-config-mapper.yaml:
  file.managed:
    - source: salt://node/install/config/mapper.yaml
    - name: {{ pillar['rbd-path'] }}/etc/rbd-node/mapper.yml
    - makedirs: True
    - template: jinja

node-uuid-conf:
  file.managed:
    - source: salt://node/install/envs/node_host_uuid.conf
    - name: {{ pillar['rbd-path'] }}/etc/rbd-node/node_host_uuid.conf
    - makedirs: True
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
    - watch:
      - file: node-script
      - file: node-uuid-conf
  cmd.run:
    - name: systemctl restart node