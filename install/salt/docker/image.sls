{% if grains['id'] == "manage01" %}
{% if not pillar.get('domain','') %}
make_domain_prepare:
  cmd.run:
    - name: echo "" > {{ pillar['rbd-path'] }}/.domain.log
    - unless: grep "goodrain" {{ pillar['rbd-path'] }}/.domain.log

make_domain:
  cmd.run:
  {% if pillar['master-public-ip'] %}
    - name: docker run  --rm  -v {{ pillar['rbd-path'] }}/.domain.log:/tmp/domain.log rainbond/archiver:domain_v2 init --ip {{ pillar['master-public-ip'] }}
  {% else %}
    - name: docker run  --rm  -v {{ pillar['rbd-path'] }}/.domain.log:/tmp/domain.log rainbond/archiver:domain_v2 init --ip {{ pillar['master-private-ip'] }}
  {% endif %}
    - unless:  grep "goodrain" {{ pillar['rbd-path'] }}/.domain.log

update_systeminfo:
  file.managed:
    - source: salt://docker/files/domain.sh
    - name: {{ pillar['rbd-path'] }}/bin/domain.sh
    - template: jinja
    - mode: 755
    - makedirs: Ture
  cmd.run:
    - name: bash {{ pillar['rbd-path'] }}/bin/domain.sh


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


