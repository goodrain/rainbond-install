{% if grains['id'] == "manage01" %}
salt-master-install:
  pkg.installed:
    - pkgs:
      - salt-master
    - refresh: True
  {% if grains['os_family']|lower == 'redhat' %}
    - unless: rpm -qa | grep salt-master
  {% else %}
    - unless: dpkg -l | grep salt-master
  {% endif %}

salt-master-conf:
  file.managed:
    - name: /etc/salt/master.d/master.conf
    - source: salt://salt/install/conf/master.conf
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - require:
      - pkg: salt-master-install

master_service:
  service.running:
    - name: salt-master
    - enable: True
    - require:
      - file: salt-master-conf
{% endif%}

salt-repo:
  pkgrepo.managed:
  {% if grains['os_family']|lower == 'redhat' %}
    {% if pillar['install-type']=='offline' %}
      {% if grains['id']=="manage01" %}
    - humanname: local_repo
    - baseurl: file://{{ pillar['install-script-path' ]}}/install/pkgs
    - enabled: 1
    - gpgcheck: 0
      # compute
      {% else %}
    - humanname: local_repo
    - baseurl: http://repo.goodrain.me/
    - enabled: 1
    - gpgcheck: 0
      {% endif %}
    # online
    {% else %}
    - humanname: SaltStack repo for RHEL/CentOS $releasever
    - baseurl: https://mirrors.ustc.edu.cn/salt/yum/redhat/$releasever/$basearch/archive/2017.7.5
    - enabled: 1
    - gpgcheck: 1
    - gpgkey: https://mirrors.ustc.edu.cn/salt/yum/redhat/7/$basearch/archive/2017.7.5/SALTSTACK-GPG-KEY.pub
    {% endif %}
  # debian or ubuntu
  {% else %}
    - name: deb http://mirrors.ustc.edu.cn/salt/apt/debian/9/amd64/2017.7 stretch main
    - file: /etc/apt/sources.list.d/salt.list
    - key_url: http://mirrors.ustc.edu.cn/salt/apt/debian/9/amd64/2017.7/SALTSTACK-GPG-KEY.pub
  {% endif %}  
    - require_in:
      - pkg: salt-minion-install
      - pkg: salt-master-install

salt-minion-install:
  pkg.installed:
    - pkgs:
      - salt-minion
    - refresh: True
    - require:
      - pkgrepo: salt-repo
  {% if grains['os_family']|lower == 'redhat' %}
    - unless: rpm -qa | grep salt-minion
  {% else %}
    - unless: dpkg -l | grep salt-minion
  {% endif %}

salt-minion-conf:
  file.managed:
    - name: /etc/salt/minion.d/minion.conf
    - source: salt://salt/install/conf/minion.conf
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - defaults:
      minion_id: {{ grains['id'] }}
    - require:
      - pkg: salt-minion-install

salt-minion-script:
  file.managed:
    - name: /tmp/salt-minion-install
    - source: salt://salt/install/script/getip.sh
    - user: root
    - group: root
    - mode: 777
    - template: jinja

salt-minion-exconf:
  cmd.run:
    - name: bash -x /tmp/salt-minion-install


minion_service:
  service.running:
    - name: salt-minion
    - enable: True
    - require:
      - file: salt-minion-conf
      - cmd: salt-minion-exconf

{% if grains['os_family']|lower == 'debian' %}

salt-master-restart:
  cmd.run:
    - name: systemctl restart salt-master.service

salt-minion-restart:
  cmd.run:
    - name: systemctl restart salt-minion.service
    - require:
      - cmd: salt-master-restart

{% endif %}