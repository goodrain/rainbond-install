include:
{% if grains['id'] == "manage01" %}
- storage.server
{% else %}
- storage.client
{% endif %}