include:
{% if grains['id'] == "manage01" %}
{% if pillar['install-type'] == 'offline' %}
  - image.exec
  - image.load
{% else %}
  - image.preinit
  - image.image
{% endif %}
  - image.tools
  - image.ssl
{% else %}
  - image.eximage
{% endif %}
  - image.rsync