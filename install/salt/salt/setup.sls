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

salt-api-install:
  pkg.installed:
    - pkgs:
      - salt-api
    - refresh: True
  {% if grains['os_family']|lower == 'redhat' %}
    - unless: rpm -qa | grep salt-api
  {% else %}
    - unless: dpkg -l | grep salt-api
  {% endif %}

salt-master-conf:
  file.managed:
    - name: /etc/salt/master.d/master.conf
    - source: salt://salt/install/conf/master.conf
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - makedirs: True
    - require:
      - pkg: salt-master-install

master_service:
  service.running:
    - name: salt-master
    - enable: True
    - require:
      - file: salt-master-conf

salt-minion-install:
  pkg.installed:
    - pkgs:
      - salt-minion
    - refresh: True
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
    - makedirs: True
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

salt-api-conf:
  file.managed:
    - name: /etc/salt/master.d/api.conf
    - source: salt://salt/install/conf/api.conf
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - makedirs: True
    - require:
      - pkg: salt-master-install
      - pkg: salt-api-install
      - pkg: salt-minion-install

# create user for salt-api
saltapi:
  user.present:
    - password: {{ pillar['secretkey'] }}

#salt-call --local tls.create_self_signed_cert:
#  cmd.run:
#    - creates: /etc/pki/tls/certs/localhost.key
#    - creates: /etc/pki/tls/certs/localhost.crt

salt-api:
  service.running:
    - enable: True
    - require:
        - file: /etc/salt/master.d/api.conf
    - watch:
        - file: /etc/salt/master.d/api.conf

{% if grains['os_family']|lower == 'debian' %}

salt-master-restart:
  cmd.run:
    - name: systemctl restart salt-master.service

salt-minion-restart:
  cmd.run:
    - name: systemctl restart salt-minion.service
    - require:
      - cmd: salt-master-restart

salt-api-restart:
  cmd.run:
    - name: systemctl restart salt-api.service
    - require:
      - cmd: salt-master-restart
{% endif %}

test_token:
  cmd.run:
    - name: bash /srv/salt/salt/install/script/token_check.sh
