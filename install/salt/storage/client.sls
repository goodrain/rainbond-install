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
{% else %}
{% if grains['os_family']|lower == 'redhat' %}
gfs_server:
  pkg.installed:
    - name: glusterfs-fuse
    - unless: rpm -qa | grep glusterfs-fuse
{% endif %}
{% endif %}

/etc/fstab:
  file.append:
    - text:
      - "{{ pillar['master-private-ip'] }}:/grdata /grdata nfs rw 0 0"
    - unless: df -h | grep /grdata

automount:
  cmd.run:
    - name: mount /grdata
    - unless: df -h | grep /grdata