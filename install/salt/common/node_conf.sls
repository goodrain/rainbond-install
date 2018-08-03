node-conf:
  file.managed:
    - source: salt://install/files/conf/all.yaml
{% if "manage" in grains['id'] %}    
    - name: {{ pillar['rbd-path'] }}/conf/master.yaml
{% else %}
    - name: {{ pillar['rbd-path'] }}/conf/worker.yaml
{% endif %}
    - template: jinja
    - makedirs: True
    - mode: 644
    - user: root
    - group: root