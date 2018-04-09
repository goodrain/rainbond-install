{% if grains['host'] == 'manage01' %}
rsync_bin_first_node:
  cmd.run:
    - name: cp -a /srv/salt/misc/file/bin/manage/* /usr/local/bin/
{% else %}
    {% if "manage" in grains['host'] %}
rsync_cli_bin_manage:
  file.recurse:
    - source: salt://misc/file/bin/manage
    - name: /usr/local/bin
    - template: jinja
    - user: root
    - group: root   
    {% else %}
rsync_cli_bin_compute:
  file.recurse:
    - source: salt://misc/file/bin/compute
    - name: /usr/local/bin
    - template: jinja
    - user: root
    - group: root  
    {% endif %}
{% endif %}