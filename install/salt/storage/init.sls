include:
{% if grains['host'] == "manage01" %}
- storage.server
{% else %}
- storage.client
{% endif %}