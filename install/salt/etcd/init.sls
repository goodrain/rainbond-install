{%- if pillar.etcd is defined %}
include:
{%- if pillar.etcd.server is defined %}
- etcd.server
{%- endif %}
{%- endif %}