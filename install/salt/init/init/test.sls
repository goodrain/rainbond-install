{% for DIR in pillar['rbd-path'] %}
{{ DIR }}/rainbond/etc/cni:
  file.directory:
   - user: rain
   - group: rain
   - mode: 755
   - makedirs: Ture
   - recurse:
     - user
     - group
     - mode
{% endfor %}
