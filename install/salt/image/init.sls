include:
{% if grains['id'] == pillar['master-hostname'] %}
{% if pillar['install-type'] == 'offline' %}
  - image.exec
  - image.tools
  - image.load
{% else %}
  - image.preinit
  - image.tools
  - image.image
{% endif %}
  - image.ssl
{% else %}
  - image.eximage
  - image.tools
{% endif %}
  - image.rsync