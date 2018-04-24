include:
- proxy.setup
{% if "manage" in grains['id'] %}
- proxy.manage
{% else %}
- proxy.compute
{% endif %}