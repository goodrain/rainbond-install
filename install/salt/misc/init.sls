include:
{% if grains['id'] == "manage01" %}
  - misc.onenode
  - misc.kubeproxy
{% endif %}
  - misc.prepare