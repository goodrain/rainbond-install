docker-envs:
  file.managed:
    - source: salt://docker/files/docker.sh
    - name: {{ pillar['rbd-path'] }}/envs/docker.sh
    - template: jinja
    - makedirs: True

docker-envs-old:
  file.managed:
    - source: salt://docker/files/docker.sh
    - name: /etc/goodrain/envs/docker.sh
    - template: jinja
    - makedirs: True

docker-mirrors:
  file.managed:
    - source: salt://docker/files/daemon.json
    - name: /etc/docker/daemon.json
    - template: jinja
    - makedirs: True

docker-repo:
  pkgrepo.managed:
  {% if grains['os_family']|lower == 'redhat' %}
    - humanname: Goodrain CentOS-$releasever - for x86_64
    - baseurl: http://repo.goodrain.com/centos/$releasever/3.5/$basearch
    - enabled: 1
    - gpgcheck: 1
    - gpgkey: http://repo.goodrain.com/gpg/RPM-GPG-KEY-CentOS-goodrain
  {% else %}
    - name: deb http://repo.goodrain.com/debian/9 3.5 main
    - file: /etc/apt/sources.list.d/docker.list
    - key_url: http://repo.goodrain.com/gpg/goodrain-C4CDA0B7
  {% endif %}  
    - require_in:
      - pkg: gr-docker-engine

gr-docker-engine:
  pkg.installed:
    - refresh: True
    - require:
      - file: docker-envs
  {% if grains['os_family']|lower == 'debian' %}
      - file: docker-envs-old
  {% endif%}    
  {% if grains['os_family']|lower == 'redhat' %}
    - unless: rpm -qa | grep gr-docker-engine
  {% else %}
    - skip_verify: True
    - unless: dpkg -l | grep gr-docker-engine
  {% endif %}

docker_service:
  file.managed:
    - source: salt://docker/files/docker.service
  {% if grains['os_family']|lower == 'redhat' %}
    - name: /usr/lib/systemd/system/docker.service
  {% else %}
    - name: /lib/systemd/system/docker.service
  {% endif %}
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

install-docker-compose:
  file.managed:
    - name: /usr/local/bin/dc-compose
    - source: salt://docker/files/dc-compose
    - makedirs: True
    - template: jinja
    - mode: 755
    - user: root
    - group: root