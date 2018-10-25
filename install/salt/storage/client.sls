{% if pillar.storage.get('type','nfs') == 'nfs' %}
nfs_client:
  pkg.installed:
   {% if grains['os_family']|lower == 'redhat' %}
    - name: nfs-utils
    - unless: rpm -qa | grep nfs-utils
   {% else %}
    - name: nfs-common
    - unless: dpkg -l | grep nfs-common
   {% endif %}
/etc/fstab:
  file.append:
    - text:
      - "{{ pillar['master-private-ip'] }}:/grdata /grdata nfs rw 0 0"
    - unless: df -h | grep /grdata

{% else %}
{% if grains['os_family']|lower == 'redhat' %}
gfs_server:
  pkg.installed:
    - name: glusterfs-fuse
    - unless: rpm -qa | grep glusterfs-fuse
{% endif %}

hosts_config:
  file.managed:
    - source: salt://install/files/storage/storage.hosts
    - name: /tmp/storage.hosts
    - user: root
    - group: root
    - mode: 777
    - makedirs: True

hosts_rewrite:
  cmd.run:
    - name: cat /tmp/storage.hosts >> /etc/hosts

/etc/fstab:
  file.append:
    - text:
      - "{{ pillar.storage.get('client_args') }}"
    - unless: df -h | grep /grdata
{% endif %}

automount:
  cmd.run:
    - name: mount -a
    - unless: df -h | grep /grdata