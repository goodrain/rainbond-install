include:
{% if "manage" in grains['id'] %}
  - init.key_build
  - init.plugins
{% else %}
  - init.gr_bin
  - init.create_dir
  - init.swap
  - init.config
  - init.user
  - init.router
  - init.key_cp
  - init.service
{% endif %}