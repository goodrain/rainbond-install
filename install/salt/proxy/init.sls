include:
- proxy.setup
{% if pillar['role'] |lower == 'manage' %}
- proxy.manage
{% else %}
- proxy.compute
{% endif %}