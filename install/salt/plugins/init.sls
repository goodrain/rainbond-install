docker-pull-worker-image:
  cmd.run:
    - name: docker pull rainbond/rbd-worker:{{ pillar['rbd-version'] }}

worker-upstart:
  cmd.run:
    - name: dc-compose up -d rbd-worker
    - unless: docker images | grep rainbond/rbd-worker:{{ pillar['rbd-version'] }}

docker-pull-eventlog-image:
  cmd.run:
    - name: docker pull rainbond/rbd-eventlog:{{ pillar['rbd-version'] }}

eventlog-upstart:
  cmd.run:
    - name: dc-compose up -d rbd-eventlog
    - unless: docker images | grep rainbond/rbd-eventlog:{{ pillar['rbd-version'] }}

docker-pull-entrance-image:
  cmd.run:
    - name: docker pull rainbond/rbd-entrance:{{ pillar['rbd-version'] }}

entrance-upstart:
  cmd.run:
    - name: dc-compose up -d rbd-entrance
    - unless: docker images | grep rainbond/rbd-entrance:{{ pillar['rbd-version'] }}

docker-pull-api-image:
  cmd.run:
    - name: docker pull rainbond/rbd-api:{{ pillar['rbd-version'] }}

api-upstart:
  cmd.run:
    - name: dc-compose up -d rbd-api
    - unless: docker images | grep rainbond/rbd-api:{{ pillar['rbd-version'] }}

docker-pull-chaos-image:
  cmd.run:
    - name: docker pull rainbond/rbd-chaos:{{ pillar['rbd-version'] }}

chaos-upstart:
  cmd.run:
    - name: dc-compose up -d rbd-chaos
    - unless: docker images | grep rainbond/rbd-chaos:{{ pillar['rbd-version'] }}

docker-pull-lb-image:
  cmd.run:
    - name: docker pull rainbond/rbd-lb:{{ pillar['rbd-version'] }}

lb-upstart:
  cmd.run:
    - name: dc-compose up -d rbd-lb
    - unless: docker images | grep rainbond/rbd-lb:{{ pillar['rbd-version'] }}

docker-pull-mq-image:
  cmd.run:
    - name: docker pull rainbond/rbd-mq:{{ pillar['rbd-version'] }}

mq-upstart:
  cmd.run:
    - name: dc-compose up -d rbd-mq
    - unless: docker images | grep rainbond/rbd-mq:{{ pillar['rbd-version'] }}

docker-pull-webcli-image:
  cmd.run:
    - name: docker pull rainbond/rbd-webcli:{{ pillar['rbd-version'] }}

webcli-upstart:
  cmd.run:
    - name: dc-compose up -d rbd-webcli
    - unless: docker images | grep rainbond/rbd-webcli:{{ pillar['rbd-version'] }}

docker-pull-app-ui-image:
  cmd.run:
    - name: docker pull rainbond/rbd-app-ui:{{ pillar['rbd-version'] }}

app-ui-upstart:
  cmd.run:
    - name: dc-compose up -d rbd-app-ui
    - unless: docker images | grep rainbond/rbd-app-ui:{{ pillar['rbd-version'] }}

update-app-ui:
  cmd.run:
    - name: docker exec rbd-app-ui python /app/ui/manage.py migrate
    - unless: dc-compose | grep rbd-app-ui

{% if grains['host'] == "manage01" %}
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