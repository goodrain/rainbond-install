include:
{% if grains['id'] == pillar['master-hostname'] %}
- storage.server
{% else %}
- storage.client
{% endif %}