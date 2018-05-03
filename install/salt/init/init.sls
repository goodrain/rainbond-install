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
{% else %}
  - init.user
  - init.create_dir
  - init.swap
  - init.limits
  - init.service
  - init.key
  - init.gr_bin
  - init.dns
{% endif %}