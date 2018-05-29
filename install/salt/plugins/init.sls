#==================== rbd-worker ====================
{% set WORKERIMG = salt['pillar.get']('rainbond-modules:rbd-worker:image') -%}
{% set WORKERVER = salt['pillar.get']('rainbond-modules:rbd-worker:version') -%}
docker-pull-worker-image:
  cmd.run:
    - name: docker pull {{ WORKERIMG }}:{{ WORKERVER }}
    - unless: docker inspect {{ WORKERIMG }}:{{ WORKERVER }}

worker-upstart:
  cmd.run:
    - name: dc-compose up -d rbd-worker
    - unless: check_compose rbd-worker
    - require:
      - cmd: docker-pull-worker-image

#==================== rbd-eventlog ====================
{% set EVLOGIMG = salt['pillar.get']('rainbond-modules:rbd-eventlog:image') -%}
{% set EVLOGVER = salt['pillar.get']('rainbond-modules:rbd-eventlog:version') -%}
docker-pull-eventlog-image:
  cmd.run:
    - name: docker pull {{ EVLOGIMG }}:{{ EVLOGVER }}
    - unless: docker inspect {{ EVLOGIMG }}:{{ EVLOGVER }}

eventlog-upstart:
  cmd.run:
    - name: dc-compose up -d rbd-eventlog
    - unless: check_compose rbd-eventlog
    - require:
      - cmd: docker-pull-eventlog-image

#==================== rbd-entrance ====================
{% set ENTRANCEIMG = salt['pillar.get']('rainbond-modules:rbd-eventlog:image') -%}
{% set ENTRANCEVER = salt['pillar.get']('rainbond-modules:rbd-eventlog:version') -%}
docker-pull-entrance-image:
  cmd.run:
    - name: docker pull {{ ENTRANCEIMG }}:{{ ENTRANCEVER }}
    - unless: docker inspect {{ ENTRANCEIMG }}:{{ ENTRANCEVER }}

entrance-upstart:
  cmd.run:
    - name: dc-compose up -d rbd-entrance
    - unless: check_compose rbd-entrance
    - require:
      - cmd: docker-pull-entrance-image

#==================== rbd-api ====================
{% set APIIMG = salt['pillar.get']('rainbond-modules:rbd-api:image') -%}
{% set APIVER = salt['pillar.get']('rainbond-modules:rbd-api:version') -%}
docker-pull-api-image:
  cmd.run:
    - name: docker pull {{ APIIMG }}:{{ APIVER }}
    - unless: docker inspect {{ APIIMG }}:{{ APIVER }}

api-upstart:
  cmd.run:
    - name: dc-compose up -d rbd-api
    - unless: check_compose rbd-api
    - require:
      - cmd: docker-pull-api-image

#==================== rbd-chaos ====================
{% set CHAOSIMG = salt['pillar.get']('rainbond-modules:rbd-chaos:image') -%}
{% set CHAOSVER = salt['pillar.get']('rainbond-modules:rbd-chaos:version') -%}
docker-pull-chaos-image:
  cmd.run:
    - name: docker pull {{ CHAOSIMG }}:{{ CHAOSVER }}
    - unless: docker inspect {{ CHAOSIMG }}:{{ CHAOSVER }}

chaos-upstart:
  cmd.run:
    - name: dc-compose up -d rbd-chaos
    - unless: check_compose rbd-chaos
    - require:
      - cmd: docker-pull-chaos-image

#==================== rbd-lb ====================
{% set LBIMG = salt['pillar.get']('rainbond-modules:rbd-lb:image') -%}
{% set LBVER = salt['pillar.get']('rainbond-modules:rbd-lb:version') -%}
docker-pull-lb-image:
  cmd.run:
    - name: docker pull {{ LBIMG }}:{{ LBVER }}
    - unless: docker inspect {{ LBIMG }}:{{ LBVER }}

default_http_conf:
  file.managed:
    - source: salt://plugins/data/proxy.conf
    - name: {{ pillar['rbd-path'] }}/etc/rbd-lb/dynamics/dynamic_servers/default.http.conf
    - template: jinja
    - makedirs: True

proxy_site_ssl:
  file.recurse:
    - source: salt://proxy/ssl/goodrain.me
    - name: {{ pillar['rbd-path'] }}/etc/rbd-lb/dynamics/dynamic_certs/goodrain.me
    - makedirs: True

lb-upstart:
  cmd.run:
    - name: dc-compose up -d rbd-lb
    - unless: check_compose rbd-lb
    - require:
      - cmd: docker-pull-lb-image
      - file: default_http_conf
      - file: proxy_site_ssl

lb-restart:
  cmd.run:
    - name: dc-compose restart rbd-lb
    - onchanges:
      - file: default_http_conf
      - file: proxy_site_ssl
    - require:
      - cmd: docker-pull-lb-image
      - file: default_http_conf
      - file: proxy_site_ssl
#==================== rbd-mq ======================
{% set MQIMG = salt['pillar.get']('rainbond-modules:rbd-mq:image') -%}
{% set MQVER = salt['pillar.get']('rainbond-modules:rbd-mq:version') -%}
docker-pull-mq-image:
  cmd.run:
    - name: docker pull {{ MQIMG }}:{{ MQVER }}
    - unless: docker inspect {{ MQIMG }}:{{ MQVER }}

mq-upstart:
  cmd.run:
    - name: dc-compose up -d rbd-mq
    - unless: check_compose rbd-mq
    - require:
      - cmd: docker-pull-mq-image

#==================== rbd-webcli ====================
{% set WEBCLIIMG = salt['pillar.get']('rainbond-modules:rbd-webcli:image') -%}
{% set WEBCLIVER = salt['pillar.get']('rainbond-modules:rbd-webcli:version') -%}
docker-pull-webcli-image:
  cmd.run:
    - name: docker pull {{ WEBCLIIMG }}:{{ WEBCLIVER }}
    - unless: docker inspect {{ WEBCLIIMG }}:{{ WEBCLIVER }}

webcli-upstart:
  cmd.run:
    - name: dc-compose up -d rbd-webcli
    - unless: check_compose rbd-webcli
    - require:
      - cmd: docker-pull-webcli-image

#==================== rbd-app-ui ====================
{% set APPUIIMG = salt['pillar.get']('rainbond-modules:rbd-app-ui:image') -%}
{% set APPUIVER = salt['pillar.get']('rainbond-modules:rbd-app-ui:version') -%}
docker-pull-app-ui-image:
  cmd.run:
    - name: docker pull {{ APPUIIMG }}:{{ APPUIVER }}
    - unless: docker inspect {{ APPUIIMG }}:{{ APPUIVER }}

app-ui-logs:
  cmd.run:
    - name: touch {{ pillar['rbd-path'] }}/logs/rbd-app-ui/goodrain.log
    - unless: ls {{ pillar['rbd-path'] }}/logs/rbd-app-ui/goodrain.log
    - require:
      - cmd: docker-pull-app-ui-image

app-ui-upstart:
  cmd.run:
    - name: dc-compose up -d rbd-app-ui
    - unless: check_compose rbd-app-ui
    - require:
      - cmd: docker-pull-app-ui-image

update-app-ui:
  cmd.run:
    - name: docker exec rbd-app-ui python /app/ui/manage.py migrate && docker exec rbd-db touch /data/.inited
    - unless: docker exec rbd-db ls /data/.inited


#==================== init region db ====================
{% if grains['id'] == "manage01" %}
update_sql:
  file.managed:
    - source: salt://plugins/data/init.sql
    - name: /tmp/init.sql
    - template: jinja
  
update_sql_sh:
  file.managed:
    - source: salt://plugins/data/init.sh
    - name: /tmp/init.sh
    - template: jinja
  cmd.run:
    - name: bash /tmp/init.sh
{% endif %}