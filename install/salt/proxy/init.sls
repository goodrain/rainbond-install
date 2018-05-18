include:
{% if "manage" in grains['id'] %}
- proxy.setup
- proxy.manage
{% else %}
- proxy.compute
{% endif %}