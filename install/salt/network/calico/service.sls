pull-calico-image:
  cmd.run:
    - name: docker pull {{ pillar.network.calico.get('image', 'rainbond/calico-node:v2.4.1') }}
    - unless: docker inspect {{ pillar.network.calico.get('image', 'rainbond/calico-node:v2.4.1') }}

calico-env:
  file.managed:
    - source: salt://network/calico/install/envs/calico.sh
    - name: {{ pillar['rbd-path'] }}/etc/envs/calico.sh
    - template: jinja
    - makedirs: Ture
    - mode: 644
    - user: root
    - group: root

calico-script:
  file.managed:
    - source: salt://network/calico/install/scripts/start.sh
    - name: {{ pillar['rbd-path'] }}/calico/scripts/start.sh
    - makedirs: Ture
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

{% if grains['host'] == 'manage01' %}
/tmp/init.calico:
  file.managed:
    - source: salt://network/calico/install/run/init.calico
    - template: jinja
    - mode: 755
    - user: root
    - group: root

init_calico:
  cmd.run: 
    - name: bash /tmp/init.calico

{% endif %}