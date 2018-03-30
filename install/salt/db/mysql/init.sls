docker-pull-db-image:
  cmd.run:
    - name: docker pull {{ pillar.database.mysql.get('image', 'rainbond/rbd-db:3.5') }}

db-upstart:
  cmd.run:
    - name: dc-compose up -d rbd-db;sleep 10
    - unless: docker images | grep {{ pillar.database.mysql.get('image', 'rainbond/rbd-db:3.5') }}

create_mysql_admin:
  cmd.run:
    - name: docker exec rbd-db mysql -e "grant all on *.* to '{{ pillar['database']['mysql']['user'] }}'@'%' identified by '{{ pillar['database']['mysql']['pass'] }}' with grant option; flush privileges";docker exec rbd-db mysql -e "delete from mysql.user where user=''; flush privileges"
    - unless: docker exec rbd-db mysql -u {{ pillar['database']['mysql']['user'] }} -P {{ pillar['database']['mysql']['port'] }} -p{{ pillar['database']['mysql']['pass'] }} -e "select user,host,grant_priv from mysql.user where user={{ pillar['database']['mysql']['user'] }}"

create_region:
  cmd.run: 
    - name: docker exec rbd-db mysql -e "CREATE DATABASE IF NOT EXISTS region DEFAULT CHARSET utf8 COLLATE utf8_general_ci;"

create_console:
  cmd.run:     
    - name: docker exec rbd-db mysql -e "CREATE DATABASE IF NOT EXISTS console DEFAULT CHARSET utf8 COLLATE utf8_general_ci;"