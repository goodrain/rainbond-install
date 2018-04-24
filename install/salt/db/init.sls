include:
{% if pillar.database.mysql is defined %}
{% if grains['id'] == 'manage01' %}
- db.mysql
{% endif %}
{% endif %}