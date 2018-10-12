include:
{% if "manage" in grains['id']%}
  - common.create_dir
  - common.key
  - common.user
  - common.limits
#  - common.swap
  - common.service
  - common.plugins
  - common.gr_bin
  - common.dns
  - common.pkg
  - common.envs
  - common.health
{% if grains['id'] == "manage01" %}
  - common.domain
{% endif %} 
{% else %}
  - common.user
  - common.create_dir
#  - common.swap
  - common.limits
  - common.service
  - common.key
  - common.gr_bin
  - common.dns
  - common.pkg
  - common.envs
  - common.health
{% endif %}