{% if pillar['role'] |lower == 'manage' %}
include:
- node.manage
{% else %}
- node.compute
{% endif %}