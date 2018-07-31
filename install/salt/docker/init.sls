include:
  - docker.install
  - docker.preinit
{% if grains['id'] == 'manage01' %}
  - docker.image
{% else %}
  - docker.eximage
{% endif %}