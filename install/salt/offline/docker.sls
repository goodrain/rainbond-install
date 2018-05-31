docker-envs:
  file.managed:
    - source: salt://docker/files/docker.sh
    - name: {{ pillar['rbd-path'] }}/envs/docker.sh
    - template: jinja
    - makedirs: True

gr-docker-engine:
  pkg.installed:
    - refresh: True
    - require:
      - file: docker-envs  
    - unless: rpm -qa | grep gr-docker-engine

docker_service:
  file.managed:
    - source: salt://docker/files/docker.service
    - name: /usr/lib/systemd/system/docker.service
    - template: jinja
    - makedirs: True

docker_status:
  service.running:
    - name: docker
    - enable: True
    - require:
      - pkg: gr-docker-engine
    - watch:
      - file: {{ pillar['rbd-path'] }}/envs/docker.sh
      - file: docker_service
      - pkg: gr-docker-engine
