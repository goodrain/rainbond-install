include:
{% if pillar.database.mysql is defined %}
{% if grains['id'] == 'manage01' %}
- db.mysql
{% else %}
- db.mysql.skip
{% endif %}
{% endif %}