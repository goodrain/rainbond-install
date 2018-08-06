include:
{% if pillar['install-type'] == 'offline' %}
  - image.exec
  - image.load
{% else %}
  - image.preinit
{% if grains['id'] == 'manage01' %}
  - image.image
{% else %}
  - image.eximage
{% endif %}
{% endif %}
{% if grains['id'] == 'manage01' %}
  - image.ssl
  - image.rsyc
{% endif %}