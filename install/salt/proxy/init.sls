include:
{% if "manage" in grains['id'] %}
- proxy.manage
{% else %}
- proxy.compute
{% endif %}