include:
{% if "manage" in grains['id'] %}
- etcd.server
{% else %}
- etcd.proxy
{% endif %}