{% if grains['id'] != "manage01" %}
salt-repo:
  pkgrepo.managed:
  {% if grains['os_family']|lower == 'redhat' %}
    {% if pillar['install-type']=='offline' %}
    - humanname: rainbond
    - baseurl: http://repo.goodrain.me/
    - enabled: 1
    - gpgcheck: 0
    # online
    {% else %}
    - humanname: SaltStack repo for RHEL/CentOS $releasever
    - baseurl: https://mirrors.ustc.edu.cn/salt/yum/redhat/7/\$basearch/archive/2018.3.2
    - enabled: 1
    - gpgcheck: 0
    - gpgkey: https://mirrors.ustc.edu.cn/salt/yum/redhat/7/$basearch/archive/2018.3.2/SALTSTACK-GPG-KEY.pub
    {% endif %}
  # debian or ubuntu
  {% else %}
    - name: deb http://mirrors.ustc.edu.cn/salt/apt/debian/9/amd64/2018.3 stretch main
    - file: /etc/apt/sources.list.d/salt.list
    - key_url: http://mirrors.ustc.edu.cn/salt/apt/debian/9/amd64/2018.3/SALTSTACK-GPG-KEY.pub
  {% endif %}  
    - require_in:
      - pkg: salt-minion-install

uninstall-urllib3:
  cmd.run:
    - name: pip uninstall -y urllib3
    - onlyif: pip show urllib3

#install salt-minion
salt-minion-install:
  pkg.installed:
    - pkgs:
      - salt-minion
    - refresh: True
    - require:
      - pkgrepo: salt-repo
      - cmd: uninstall-urllib3
  {% if grains['os_family']|lower == 'redhat' %}
    - unless: rpm -qa | grep salt-minion
  {% else %}
    - unless: dpkg -l | grep salt-minion
  {% endif %}

{% if grains['os_family']|lower == 'redhat' %}
{% if pillar['install-type']=='online' %}
epel-install:
  pkg.installed:
    - pkgs:
      - epel-release
    - refresh: True
    - unless: rpm -qa | grep epel-release
{% endif %}
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

salt-minion-restart:
  cmd.run:
    - name: systemctl restart salt-minion.service

{% endif %}