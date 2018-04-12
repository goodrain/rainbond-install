include:
{% if "manage" in grains['id'] %}
  - init.key_build
  - init.plugins
{% endif %}
  - init.gr_bin
  - init.create_dir
  - init.swap
  - init.config
  - init.user
  - init.router
  - init.key_cp
  - init.service
