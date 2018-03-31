include:
{% if "manage" in grains['host'] %}
- node.manage
{% else %}
- node.compute
{% endif %}