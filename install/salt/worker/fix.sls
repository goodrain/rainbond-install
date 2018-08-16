rename-compose:
  file.rename:
    - name: /opt/rainbond/compose_bak
    - source: /opt/rainbond/compose
    - force: True
    - makedirs: True