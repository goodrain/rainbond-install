
{% set CALICOIMG = salt['pillar.get']('network:calico:image') -%}
{% set CALICOVER = salt['pillar.get']('network:calico:version') -%}
{% set PUBDOMAIN = salt['pillar.get']('public-image-domain') -%}
{% set PRIDOMAIN = salt['pillar.get']('private-image-domain') -%}

{% if grains['id'] == 'manage01' %}
init-calico:
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
      - file: init-calico
{% else %}
pull-calico-image:
  cmd.run:
    - name: docker pull {{PRIDOMAIN}}/{{CALICOIMG}}:{{ CALICOVER }}
{% endif %}