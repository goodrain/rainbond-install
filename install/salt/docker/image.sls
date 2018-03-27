dps:
    cmd.run:
      - name: docker run --rm -v /var/run/docker.sock:/var/run/docker.sock rainbond/archiver gr-docker-utils
      - unless: which dps
    
#dc-compose:
#    cmd.run:
#      - name: docker run --rm -v /var/run/docker.sock:/var/run/docker.sock rainbond/archiver gr-docker-compose
#      - unless: which dc-compose

install-docker-compose:
  cmd.run:
    #- name: curl -L https://github.com/docker/compose/releases/download/1.20.1/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose
    - name: curl -L https://get.daocloud.io/docker/compose/releases/download/1.12.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose
    - unless: which docker-compose
  file.managed:
    - name: /usr/local/bin/dc-compose
    - source: salt://docker/envs/dc-compose
    - makedirs: Ture
    - template: jinja
    - mode: 755
    - user: root
    - group: root

