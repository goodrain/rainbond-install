docker-pull-image:
  cmd.run:
    - name: docker pull {{ pillar.database.mysql.get('image', 'rainbond/rbd-db:3.5') }}

db-upstart:
  cmd.run:
    - name: dc-compose up -d rbd-db