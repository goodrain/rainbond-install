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

minion_service:
  service.running:
    - name: salt-minion
    - enable: True
    - require:
      - file: salt-minion-conf