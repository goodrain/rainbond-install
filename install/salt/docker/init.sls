include:
{% if pillar['install-type'] == 'online'  %}
  - docker.install
  - docker.domain
{% endif %}
