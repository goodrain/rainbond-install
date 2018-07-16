include:
  - install.common.init
{% if grains['id'] == "manage01" %}
  - install.storage.server
{% else %}
  - install.storage.client
{% endif %}
