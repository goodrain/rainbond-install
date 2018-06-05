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

#handle with urllib3 package before install salt-minion
handle-urllib3:
  cmd.run:
{% if grains['os_family']|lower == 'redhat' %}
  {% if grains['id']!="manage01" %}
    - name: pip uninstall urllib3 -y  > /dev/null 2>&1
  {% endif %}
{% else %}
    - name: pip install -U urllib3 -y > /dev/null 2>&1
{% endif %}
    - onlyif:
      #- which pip > /dev/null 2>&1
      - pip show urllib3 > /dev/null 2>&1
#install salt-minion
salt-minion-install:
  pkg.installed:
    - pkgs:
      - salt-minion
    - refresh: True
    - require:
      - pkgrepo: salt-repo
      - cmd: handle-urllib3
  {% if grains['os_family']|lower == 'redhat' %}
    - unless: rpm -qa | grep salt-minion
  {% else %}
    - unless: dpkg -l | grep salt-minion
  {% endif %}

salt-minion-conf:
  file.managed:
    - name: /etc/salt/minion.d/minion.conf
    - source: salt://minions/install/conf/minion.conf
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