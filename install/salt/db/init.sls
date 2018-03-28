include:
{% if pillar.database.mysql is defined %}
- db.mysql
{% endif %}