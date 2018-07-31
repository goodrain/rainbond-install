include:
{% if grains['id'] == 'manage01' %}
  - master.db
{% endif %}
  - master.k8s
