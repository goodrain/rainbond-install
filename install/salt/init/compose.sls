{% set path = pillar['rbd-path'] %}
compose_file:
  file.managed:
{% if grains['host'] == "manage01" %}
     - source: salt://init/files/docker-compose.yaml.0
{% elif "manage" in grains['host'] %}
     - source: salt://init/files/docker-compose.yaml.1
{% endif %} 
     - name: {{ path }}/docker-compose.yaml
     - user: root
     - group: root
     - mode: 600
     - makedirs: Ture
 

