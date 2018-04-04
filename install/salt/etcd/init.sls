include:
{% if "manage" in grains['host'] %}
- etcd.server
{% else %}
- etcd.proxy
{% endif %}