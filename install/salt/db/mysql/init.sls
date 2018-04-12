docker-pull-db-image:
  cmd.run:
    - name: docker pull {{ pillar.database.mysql.get('image', 'rainbond/rbd-db:3.5') }}
    - unless: docker inspect {{ pillar.database.mysql.get('image', 'rainbond/rbd-db:3.5') }}

db-upstart:
  cmd.run:
    - name: dc-compose up -d rbd-db
    - unless: dc-compose ps | grep rbd-db | grep -v Up
    - require:
      - cmd: docker-pull-db-image

waiting_for_db:
  cmd.run:
    - name: docker exec rbd-db mysql -e "show databases"
    - require:
      - cmd: db-upstart
    - retry:
        attempts: 20
        until: True
        interval: 3
        splay: 3

create_mysql_admin:
  cmd.run:
    - name: docker exec rbd-db mysql -e "grant all on *.* to '{{ pillar['database']['mysql']['user'] }}'@'%' identified by '{{ pillar['database']['mysql']['pass'] }}' with grant option; flush privileges";docker exec rbd-db mysql -e "delete from mysql.user where user=''; flush privileges"
    - unless: docker exec rbd-db mysql -u {{ pillar['database']['mysql']['user'] }} -P {{ pillar['database']['mysql']['port'] }} -p{{ pillar['database']['mysql']['pass'] }} -e "select user,host,grant_priv from mysql.user where user={{ pillar['database']['mysql']['user'] }}"
    - require:
      - cmd: waiting_for_db
    
create_region:
  cmd.run: 
    - name: docker exec rbd-db mysql -e "CREATE DATABASE IF NOT EXISTS region DEFAULT CHARSET utf8 COLLATE utf8_general_ci;"
    - require:
      - cmd: waiting_for_db

create_console:
  cmd.run:     
    - name: docker exec rbd-db mysql -e "CREATE DATABASE IF NOT EXISTS console DEFAULT CHARSET utf8 COLLATE utf8_general_ci;"
    - require:
      - cmd: waiting_for_db