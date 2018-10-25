include:
{% if grains['id'] == "manage01" %}
- storage.server
- storage.key
{% else %}
- storage.client
{% endif %}