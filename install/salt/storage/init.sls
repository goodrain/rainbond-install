include:
{% if grains['host'] == "manage01" %}
- storage.manage
{% else %}
- storage.compute
{% endif %}