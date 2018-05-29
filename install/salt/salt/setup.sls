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
    - humanname: SaltStack repo for RHEL/CentOS $releasever
    - baseurl: https://mirrors.ustc.edu.cn/salt/yum/redhat/$releasever/$basearch/archive/2017.7.5
    - enabled: 1
    - gpgcheck: 1
    - gpgkey: https://mirrors.ustc.edu.cn/salt/yum/redhat/7/$basearch/archive/2017.7.5/SALTSTACK-GPG-KEY.pub
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

minion_service:
  service.running:
    - name: salt-minion
    - enable: True
    - require:
      - file: salt-minion-conf