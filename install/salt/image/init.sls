include:
{% if pillar['install-type'] == 'offline' %}
  - image.load
  - image.exec
{% else %}
  - image.preinit
{% if grains['id'] == 'manage01' %}
  - image.image
{% else %}
  - image.eximage
{% endif %}
{% endif %}