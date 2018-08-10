include:
{% if pillar['install-type'] == 'offline' %}
{% if grains['id'] == "manage01" %}
  - image.exec
  - image.load
{% else %}
  - image.eximage
{% endif %}
{% else %}
{% if grains['id'] == 'manage01' %}
  - image.preinit
  - image.image
{% else %}
  - image.eximage
{% endif %}
{% endif %}
{% if "manage" in grains['id'] %}
{% if grains['id'] == 'manage01' %}
  - image.ssl
{% endif %}
  - image.rsync
{% endif %}