{% if grains['id'] == 'manage01' %}
pull-calico-image:
  cmd.run:
    - name: docker pull {{ pillar.network.calico.get('image', 'rainbond/calico-node:v2.4.1') }}
    - unless: docker inspect {{ pillar.network.calico.get('image', 'rainbond/calico-node:v2.4.1') }}

calico-tag:
  cmd.run:
    - name: docker tag rainbond/calico-node:v2.4.1 goodrain.me/calico-node:v2.4.1
    - unless: docker inspect goodrain.me/calico-node:v2.4.1
    - require:
      - cmd: pull-calico-image

calico-push:
  cmd.run:
    - name: docker push goodrain.me/calico-node:v2.4.1
    - require:
      - cmd: calico-tag

{% else %}
pull-calico-image:
  cmd.run:
    - name: docker pull {{ pillar.network.calico.get('image', 'goodrain.me/calico-node:v2.4.1') }}
    - unless: docker inspect {{ pillar.network.calico.get('image', 'goodrain.me/calico-node:v2.4.1') }}
{% endif %}


calico-env:
  file.managed:
    - source: salt://network/calico/install/envs/calico.sh
    - name: {{ pillar['rbd-path'] }}/envs/calico.sh
    - template: jinja
    - makedirs: Ture
    - mode: 644
    - user: root
    - group: root

calico-script:
  file.managed:
    - source: salt://network/calico/install/scripts/start-calico.sh
    - name: {{ pillar['rbd-path'] }}/scripts/start-calico.sh
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

{% if grains['id'] == 'manage01' %}
init.calico:
  file.managed:
    - name: {{ pillar['rbd-path'] }}/bin/init.calico
    - source: salt://network/calico/install/run/init.calico
    - makedirs: Ture
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