prometheus-yml:
  file.managed:
    - source: salt://prometheus/prometheus.yml
    - name: {{ pillar['rbd-path'] }}/prometheus/prometheus.yml
    - template: jinja
    - makedirs: Ture

docker-pull-prom-image:
  cmd.run:
    - name: docker pull rainbond/prometheus:v2.0.0

prom-upstart:
  cmd.run:
    - name: dc-compose up -d prometheus
    - unless: docker images | grep rainbond/prometheus:v2.0.0
