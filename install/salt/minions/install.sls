minion_bootstrap:
  file.managed:
    - name: /tmp/bootstrap-salt.sh
    - source: salt://minions/install/scripts/bootstrap-salt.sh
    - user: root
    - group: root
    - mode: 644
minion_install:
  cmd.run:
    - name: bash /tmp/bootstrap-salt.sh -P
minion_conf:
  file.managed:
    - name: /etc/salt/minion.d/minion.conf
    - source: salt://minions/install/conf/minion.conf
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - defaults:
      minion_id: {{ grains['host'] }}
    - require:
      - cmd: minion_install
minion_service:
  service.running:
    - name: salt-minion
    - enable: True
    - watch:
      - file: minion_conf
  cmd.run:
    - name: systemctl restart salt-minion

