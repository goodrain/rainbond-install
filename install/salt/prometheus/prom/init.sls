{% set P8SIMG = salt['pillar.get']('rainbond-modules:rbd-prometheus:image') -%}
{% set P8SVER = salt['pillar.get']('rainbond-modules:rbd-prometheus:version') -%}
{% set PUBDOMAIN = salt['pillar.get']('public-image-domain') -%}
{% set PRIDOMAIN = salt['pillar.get']('private-image-domain') -%}

prometheus-yml:
  file.managed:
    - source: salt://prometheus/prom/prometheus.yml
    - name: {{ pillar['rbd-path'] }}/etc/rbd-prometheus/prometheus.yml
    - user: rain
    - group: rain
    - template: jinja
    - makedirs: True

docker-pull-prom-image:
  cmd.run:
    - name: docker pull {{PUBDOMAIN}}/{{ P8SIMG }}:{{ P8SVER }}
    - unless: docker inspect {{PUBDOMAIN}}/{{ P8SIMG }}:{{ P8SVER }}

create-prom-data:
  file.directory:
   - name: /grdata/services/rbd-prometheus/data
   - makedirs: True
   - user: rain
   - group: rain
   - mode: 755

prom-upstart:
  cmd.run:
    - name: dc-compose up -d rbd-prometheus
    - unless: check_compose rbd-prometheus
    - require:
      - file: create-prom-data
