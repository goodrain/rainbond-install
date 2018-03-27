{% if pillar.network is defined %}
include:
{% if pillar.network.calico is defined %}
- network.calico
{% endif %}
{% endif %}