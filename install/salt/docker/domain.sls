{% if grains['id'] == "manage01" %}
{% if not pillar.get('domain','') %}
make_domain_prepare:
  cmd.run:
    - name: echo "" > {{ pillar['rbd-path'] }}/.domain.log
    - unless: grep "goodrain" {{ pillar['rbd-path'] }}/.domain.log

make_domain:
  file.managed:
    - source: salt://docker/files/domain.sh
    - name: {{ pillar['rbd-path'] }}/bin/domain.sh
    - template: jinja
    - mode: 755
    - makedirs: Ture
  cmd.run:
  {% if pillar['public-ip'] %}
    - name: bash {{ pillar['rbd-path'] }}/bin/domain.sh {{ pillar['master-public-ip'] }}
  {% else %}
    - name: bash {{ pillar['rbd-path'] }}/bin/domain.sh {{ pillar['master-private-ip'] }}
  {% endif %}

rsync_update_domain:
  file.managed:
    - source: salt://docker/files/.domain.sh
    - name: {{ pillar['rbd-path'] }}/bin/.domain.sh
    - template: jinja
    - mode: 755
    - makedirs: Ture

refresh_domain:
  cmd.run:
    - name: salt "*" saltutil.refresh_pillar
{% endif %}
{% endif %}


