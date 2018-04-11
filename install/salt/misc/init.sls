include:
{% if grains['host'] == "manage01" %}
  - misc.onenode
{% endif %}
  - misc.prepare