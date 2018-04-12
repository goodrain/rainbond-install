docker-envs:
  file.managed:
    {% if grains['os_family']|lower == 'redhat' and grains['osrelease_info'][1] == 4 %}
    - source: salt://docker/envs/docker-patch.sh
    {% else %}
    - source: salt://docker/envs/docker.sh
    {% endif %}
    - name: {{ pillar['rbd-path'] }}/etc/envs/docker.sh
    - template: jinja
    - makedirs: Ture
    - mode: 644
    - user: root

docker-mirrors:
  file.managed:
    - source: salt://docker/envs/daemon.json
    - name: /etc/docker/daemon.json
    - makedirs: Ture

docker-repo:
  pkgrepo.managed:
  {% if grains['os_family']|lower == 'redhat' %}
    - humanname: Goodrain CentOS-$releasever - for x86_64
    - baseurl: http://repo.goodrain.com/centos/\$releasever/3.5/\$basearch
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
      - file: {{ pillar['rbd-path'] }}/etc/envs/docker.sh
  {% if grains['os_family']|lower == 'redhat' %}
    - unless: rpm -qa | grep gr-docker-engine
  {% else %}
    - unless: dpkg -l | grep gr-docker-engine
  {% endif %}
  
  file.managed:
    - source: salt://docker/envs/docker.service
    - name: /usr/lib/systemd/system/docker.service
    - template: jinja
  service.running:
    - name: docker
    - enable: True
    - require:
      - pkg: gr-docker-engine
    - watch:
      - file: {{ pillar['rbd-path'] }}/etc/envs/docker.sh
      - file: /usr/lib/systemd/system/docker.service
      - pkg: gr-docker-engine


install-docker-compose:
  file.managed:
    - name: /usr/local/bin/dc-compose
    - source: salt://docker/envs/dc-compose
    - makedirs: Ture
    - template: jinja
    - mode: 755
    - user: root
    - group: root
