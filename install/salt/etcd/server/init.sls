include:
  - etcd.server.service
{% if pillar.etcd.server.setup is defined %}
- etcd.server.setup
{% endif %}