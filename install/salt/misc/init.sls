include:
{% if grains['id'] == "manage01" %}
  - misc.onenode
{% endif %}
  - misc.prepare