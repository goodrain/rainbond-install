{% if "manage" in grains['id'] %}
{% if pillar.domain is defined %}
compose_base_file:
  file.managed:
     - source: salt://install/files/tpl/base.yaml
     - name: {{ pillar['rbd-path'] }}/compose/base.yaml
     - makedirs: True
     - template: jinja
compose_lb_file:
  file.managed:
     - source: salt://install/files/tpl/lb.yaml
     - name: {{ pillar['rbd-path'] }}/compose/lb.yaml
     - makedirs: True
     - template: jinja
compose_ui_file:
  file.managed:
     - source: salt://install/files/tpl/ui.yaml
     - name: {{ pillar['rbd-path'] }}/compose/ui.yaml
     - makedirs: True
     - template: jinja
compose_plugin_file:
  file.managed:
     - source: salt://install/files/tpl/plugin.yaml
     - name: {{ pillar['rbd-path'] }}/compose/plugin.yaml
     - makedirs: True
     - template: jinja
{% endif %}
{% endif %}