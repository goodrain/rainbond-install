{% set DBPORT = salt['pillar.get']('database:mysql:port') -%}
{% set DBUSER = salt['pillar.get']('database:mysql:user') -%}
{% set DBPASS = salt['pillar.get']('database:mysql:pass') -%}

my.cnf:
  file.managed:
    - source: salt://install/files/db/mysql/my.cnf
    - name: {{ pillar['rbd-path'] }}/etc/rbd-db/my.cnf
    - makedirs: True

charset.cnf:
  file.managed:
    - source: salt://install/files/db/mysql/charset.cnf
    - name: {{ pillar['rbd-path'] }}/etc/rbd-db/conf.d/charset.cnf
    - makedirs: True

db-upstart:
  cmd.run:
    - name: dc-compose up -d rbd-db
    - unless: check_compose rbd-db
    - require:
      - cmd: docker-pull-db-image
      - file: charset.cnf
      - file: my.cnf

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
    - name: docker exec rbd-db mysql -e "grant all on *.* to '{{ DBUSER }}'@'%' identified by '{{ DBPASS }}' with grant option; flush privileges";docker exec rbd-db mysql -e "delete from mysql.user where user=''; flush privileges"
    - unless: docker exec rbd-db mysql -u {{ DBUSER }} -P {{ DBPORT }} -p{{ DBPASS }} -e "select user,host,grant_priv from mysql.user where user={{ DBUSER }}"
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