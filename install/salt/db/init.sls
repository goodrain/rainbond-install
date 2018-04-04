include:
{% if pillar.database.mysql is defined %}
{% if grains['host'] == 'manage01' %}
- db.mysql
{% endif %}
{% endif %}