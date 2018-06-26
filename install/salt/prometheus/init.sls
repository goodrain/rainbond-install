include:
{% if "manage" in grains['id'] %}
- prometheus.prom
{% endif %}