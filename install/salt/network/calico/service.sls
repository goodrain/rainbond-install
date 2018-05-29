{% set CALICOIMG = salt['pillar.get']('network:calico:image') -%}
{% set CALICOVER = salt['pillar.get']('network:calico:version') -%}

pull-calico-image:
  cmd.run:
    - name: docker pull {{ CALICOIMG }}:{{ CALICOVER }}
    - unless: docker inspect {{ CALICOIMG }}:{{ CALICOVER }}

calico-env:
  file.managed:
    - source: salt://network/calico/install/envs/calico.sh
    - name: {{ pillar['rbd-path'] }}/envs/calico.sh
    - template: jinja
    - makedirs: True
    - mode: 644
    - user: root
    - group: root

calico-script:
  file.managed:
    - source: salt://network/calico/install/scripts/start-calico.sh
    - name: {{ pillar['rbd-path'] }}/scripts/start-calico.sh
    - makedirs: True
    - template: jinja
    - mode: 755
    - user: root
    - group: root

/etc/systemd/system/calico.service:
  file.managed:
    - source: salt://network/calico/install/systemd/calico.service
    - template: jinja
    - user: root
    - group: root

calico:
  service.running:
    - enable: True
    - watch:
      - file: calico-script
      - file: calico-env
      - cmd: pull-calico-image
    - require:
      - file: /etc/systemd/system/calico.service
      - file: calico-script
      - file: calico-env
      - cmd: pull-calico-image

{% if grains['id'] == 'manage01' %}
init.calico:
  file.managed:
    - name: {{ pillar['rbd-path'] }}/bin/init.calico
    - source: salt://network/calico/install/run/init.calico
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