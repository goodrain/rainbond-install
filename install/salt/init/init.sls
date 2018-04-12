include:
{% if "manage" in grains['id']%}
  - init.key_build
  - init.user
  - init.config
  - init.swap
  - init.create_dir
  - init.service
  - init.router
  - init.key_cp
  - init.plugins
  - init.gr_bin
{% else %}
  - init.user
  - init.create_dir
  - init.swap
  - init.config
  - init.service
  - init.key_cp
  - init.router
  - init.gr_bin
{% endif %}