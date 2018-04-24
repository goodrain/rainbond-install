#==================== rbd-worker ====================
docker-pull-worker-image:
  cmd.run:
    - name: docker pull rainbond/rbd-worker:{{ pillar['rbd-version'] }}
    - unless: docker inspect rainbond/rbd-worker:{{ pillar['rbd-version'] }}

worker-upstart:
  cmd.run:
    - name: dc-compose up -d rbd-worker
    - unless: check_compose rbd-worker
    - require:
      - cmd: docker-pull-worker-image

#==================== rbd-eventlog ====================
docker-pull-eventlog-image:
  cmd.run:
    - name: docker pull rainbond/rbd-eventlog:{{ pillar['rbd-version'] }}
    - unless: docker inspect rainbond/rbd-eventlog:{{ pillar['rbd-version'] }}

eventlog-upstart:
  cmd.run:
    - name: dc-compose up -d rbd-eventlog
    - unless: check_compose rbd-eventlog
    - require:
      - cmd: docker-pull-eventlog-image

#==================== rbd-entrance ====================
docker-pull-entrance-image:
  cmd.run:
    - name: docker pull rainbond/rbd-entrance:{{ pillar['rbd-version'] }}
    - unless: docker inspect rainbond/rbd-entrance:{{ pillar['rbd-version'] }}

entrance-upstart:
  cmd.run:
    - name: dc-compose up -d rbd-entrance
    - unless: check_compose rbd-entrance
    - require:
      - cmd: docker-pull-entrance-image

#==================== rbd-api ====================
docker-pull-api-image:
  cmd.run:
    - name: docker pull rainbond/rbd-api:{{ pillar['rbd-version'] }}
    - unless: docker inspect rainbond/rbd-api:{{ pillar['rbd-version'] }}

api-upstart:
  cmd.run:
    - name: dc-compose up -d rbd-api
    - unless: check_compose rbd-api
    - require:
      - cmd: docker-pull-api-image

#==================== rbd-chaos ====================
docker-pull-chaos-image:
  cmd.run:
    - name: docker pull rainbond/rbd-chaos:{{ pillar['rbd-version'] }}
    - unless: docker inspect rainbond/rbd-chaos:{{ pillar['rbd-version'] }}

chaos-upstart:
  cmd.run:
    - name: dc-compose up -d rbd-chaos
    - unless: check_compose rbd-chaos
    - require:
      - cmd: docker-pull-chaos-image

#==================== rbd-lb ====================
docker-pull-lb-image:
  cmd.run:
    - name: docker pull rainbond/rbd-lb:{{ pillar['rbd-version'] }}
    - unless: docker inspect rainbond/rbd-lb:{{ pillar['rbd-version'] }}

proxy_site_conf:
  file.managed:
    - source: salt://plugins/data/proxy.conf
    - name: {{ pillar['rbd-path'] }}/openresty/servers/http/proxy.conf
    - template: jinja
    - makedirs: Ture

proxy_site_ssl:
  file.recurse:
    - source: salt://proxy/ssl/goodrain.me
    - name: {{ pillar['rbd-path'] }}/openresty/ssl/goodrain.me
    - makedirs: Ture

lb-upstart:
  cmd.run:
    - name: dc-compose up -d rbd-lb
    - unless: check_compose rbd-lb
    - require:
      - cmd: docker-pull-lb-image
      - file: proxy_site_conf
      - file: proxy_site_ssl

lb-restart:
  cmd.run:
    - name: dc-compose restart rbd-lb
    - onchanges:
      - file: proxy_site_conf
      - file: proxy_site_ssl
    - require:
      - cmd: docker-pull-lb-image
      - file: proxy_site_conf
      - file: proxy_site_ssl
#==================== rbd-mq ======================
docker-pull-mq-image:
  cmd.run:
    - name: docker pull rainbond/rbd-mq:{{ pillar['rbd-version'] }}
    - unless: docker inspect rainbond/rbd-mq:{{ pillar['rbd-version'] }}

mq-upstart:
  cmd.run:
    - name: dc-compose up -d rbd-mq
    - unless: check_compose rbd-mq
    - require:
      - cmd: docker-pull-mq-image

#==================== rbd-webcli ====================
docker-pull-webcli-image:
  cmd.run:
    - name: docker pull rainbond/rbd-webcli:{{ pillar['rbd-version'] }}
    - unless: docker inspect rainbond/rbd-webcli:{{ pillar['rbd-version'] }}

webcli-upstart:
  cmd.run:
    - name: dc-compose up -d rbd-webcli
    - unless: check_compose rbd-webcli
    - require:
      - cmd: docker-pull-webcli-image

#==================== rbd-app-ui ====================
docker-pull-app-ui-image:
  cmd.run:
    - name: docker pull rainbond/rbd-app-ui:{{ pillar['rbd-version'] }}
    - unless: docker inspect rainbond/rbd-app-ui:{{ pillar['rbd-version'] }}

app-ui-logs:
  cmd.run:
    - name: touch {{ pillar['rbd-path'] }}/logs/service_logs/goodrain_web/goodrain.log
    - unless: ls {{ pillar['rbd-path'] }}/logs/service_logs/goodrain_web/goodrain.log
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