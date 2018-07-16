{% if grains['id'] == 'manage01' %}
init.calico:
  file.managed:
    - name: {{ pillar['rbd-path'] }}/bin/init.calico
    - source: salt://install/files/network/calico/init.calico
    - makedirs: True
    - template: jinja
    - mode: 755
    - user: root
    - group: root

init_calico:
  cmd.run: 
    - name: bash {{ pillar['rbd-path'] }}/bin/init.calico
    - require:
      - file: init.calico

{% endif %}