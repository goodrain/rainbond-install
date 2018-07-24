{% set DIR = salt['pillar.get']('rbd-path','/opt/rainbond') %}

rename-compose:
  file.rename:
    - name: {{ DIR }}/compose_bak
    - source: {{ DIR }}/compose
    - force: True
