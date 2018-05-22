{% set P8SIMG = salt['pillar.get']('rainbond-modules:rbd-prometheus:image') -%}
{% set P8SVER = salt['pillar.get']('rainbond-modules:rbd-prometheus:version') -%}
prometheus-yml:
  file.managed:
    - source: salt://prometheus/prom/prometheus.yml
    - name: {{ pillar['rbd-path'] }}/etc/rbd-prometheus/prometheus.yml
    - user: rain
    - group: rain
    - template: jinja
    - makedirs: Ture

docker-pull-prom-image:
  cmd.run:
    - name: docker pull {{ P8SIMG }}:{{ P8SVER }}
    - unless: docker inspect {{ P8SIMG }}:{{ P8SVER }}

create-prom-data:
  file.directory:
   - name: /grdata/services/rbd-prometheus/data
   - makedirs: True
   - user: rain
   - group: rain
   - mode: 755

prom-upstart:
  cmd.run:
    - name: dc-compose up -d prometheus
    - unless: check_compose prometheus
    - require:
      - file: create-prom-data
