# NFS Server states
nfs_server:
  pkg.installed:
   {% if grains['os_family']|lower == 'redhat' %}
    - name: nfs-utils
    - unless: rpm -qa | grep nfs-utils
   {% else %}
    - name: nfs-kernel-server
    - unless: dpkg -l | grep nfs-kernel-server
   {% endif %}

nfs_server_running:
  service.running:
    - name: nfs-server
    - enable: True
    - require:
      - pkg: nfs_server
    - watch:
      - file: server_exports

server_exports:
  file.managed:
    - name: /etc/exports
    - source: salt://storage/file/exports
    - user: root
    - group: root
    - mode: 644

update_exports:
  cmd.run:
    - name: exportfs -ra
    - require:
      - pkg: nfs_server
    - onchanges:
      - file: server_exports

show_exports:
  cmd.run:
    - name: showmount -e 127.0.0.1



