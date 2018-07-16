node-uuid-conf:
  file.managed:
    - source: salt://install/files/node/node_host_uuid.conf
    - name: {{ pillar['rbd-path'] }}/etc/rbd-node/node_host_uuid.conf
    - makedirs: True
    - template: jinja

node:
  service.running:
    - enable: True
    - watch:
      - file: node-script
      - file: node-uuid-conf
  cmd.run:
    - name: systemctl restart node