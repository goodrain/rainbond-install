include:
{% if pillar['install-type'] == 'offline' %}
{% if grains['id'] == "manage01" %}
  - image.exec
  - image.load
{% else %}
  - image.eximage
{% endif %}
{% else %}
  - image.preinit
{% if grains['id'] == 'manage01' %}
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