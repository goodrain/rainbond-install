{% set P8SIMG = salt['pillar.get']('rainbond-modules:rbd-monitor:image') -%}
{% set P8SVER = salt['pillar.get']('rainbond-modules:rbd-monitor:version') -%}
{% set PUBDOMAIN = salt['pillar.get']('public-image-domain') -%}
{% set PRIDOMAIN = salt['pillar.get']('private-image-domain') -%}

prometheus-yml:
  file.touch:
    - name: {{ pillar['rbd-path'] }}/etc/rbd-prometheus/prometheus.yml
    - makedirs: True

docker-pull-prom-image:
  cmd.run:
  {% if pillar['install-type']!="offline" %}
    - name: docker pull {{PUBDOMAIN}}/{{ P8SIMG }}:{{ P8SVER }}
  {% else %}
    - name: docker load -i {{ pillar['install-script-path'] }}/install/imgs/{{PUBDOMAIN}}_{{ P8SIMG }}_{{ P8SVER }}.gz
  {% endif %}
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
    - name: dc-compose up -d rbd-monitor
    - unless: check_compose rbd-monitor
    - require:
      - file: create-prom-data
