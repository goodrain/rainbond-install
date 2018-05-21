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
      - "{{ pillar['master-ip'] }}:/grdata /grdata nfs rw 0 0"
    - require:
      - pkg: nfs_client

automount:
  cmd.run:
    - name: mount /grdata
    - unless: ls /grdata/services