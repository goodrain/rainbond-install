include:
{% if grains['id'] == 'manage01' %}
- prometheus.prom
{% endif %}