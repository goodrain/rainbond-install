docker-envs:
  file.managed:
    - source: salt://docker/files/docker.sh
    - name: {{ pillar['rbd-path'] }}/envs/docker.sh
    - template: jinja
    - makedirs: Ture

gr-docker-engine:
  pkg.installed:
    - refresh: True
    - require:
      - file: docker-envs  
    - unless: rpm -qa | grep gr-docker-engine