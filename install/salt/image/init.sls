include:
{% if grains['id'] == "manage01" %}
{% if pillar['install-type'] == 'offline' %}
  - image.exec
  - image.tools
  - image.load
{% else %}
  - image.preinit
  - image.tools
  - image.image
{% endif %}
{% else %}
  - image.eximage
  - image.tools
{% endif %}
  - image.rsync