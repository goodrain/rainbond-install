{% set path = pillar['rbd-path'] %}
check_domain:
  cmd.run:
    - name:  echo "domain not found"
    - unless: grep "domain" {{ pillar['install-script-path'] }}/install/pillar/system_info.sls

refresh_domain:
  cmd.run:
    - name: salt "*" saltutil.refresh_pillar

{% if pillar.domain is defined %}
compose_file:
  file.managed:
     - source: salt://init/files/docker-compose.yaml
     - name: {{ path }}/docker-compose.yaml
     - makedirs: Ture
     - template: jinja
     - require:
        - cmd: refresh_domain
{% endif %}