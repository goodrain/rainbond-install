include:
{% if grains['id'] == pillar['master-hostname'] %}
  - master.db
{% endif %}
  - master.k8s
