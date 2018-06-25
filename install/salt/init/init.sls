include:
{% if "manage" in grains['id']%}
  - init.key
  - init.user
  - init.limits
  - init.swap
  - init.create_dir
  - init.service
  - init.plugins
  - init.gr_bin
  - init.dns
  - init.pkg
  - init.envs
{% if grains['id'] == "manage01" %}
  - init.domain
{% endif %} 
{% else %}
  - init.user
  - init.create_dir
  - init.swap
  - init.limits
  - init.service
  - init.key
  - init.gr_bin
  - init.dns
  - init.pkg
  - init.envs
{% endif %}