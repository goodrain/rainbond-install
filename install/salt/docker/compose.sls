{% set path = pillar['rbd-path'] %}
compose_file:
  file.managed:
     - source: salt://init/files/docker-compose.yaml
     - name: {{ path }}/docker-compose.yaml
     - user: root
     - group: root
     - mode: 600
     - makedirs: Ture
     - template: jinja