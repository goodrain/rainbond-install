include:
  - docker.install
{% if grains['id'] == 'manage01' %}
  - docker.image
{% else %}
  - docker.eximage
{% endif %}
  - docker.misc