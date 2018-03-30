include:
- proxy.setup
{% if "manage" in grains['host'] %}
- proxy.manage
{% else %}
- proxy.compute
{% endif %}