include:
{% if grains['host'] == 'manage01' %}
- prometheus.prom
{% endif %}