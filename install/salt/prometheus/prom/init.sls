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
    - name: docker pull rainbond/prometheus:v2.0.0
    - unless: docker inspect rainbond/prometheus:v2.0.0

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
