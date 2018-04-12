nfs_client:
  pkg.installed:
   {% if grains['os_family']|lower == 'redhat' %}
    - name: nfs-utils
    - unless: rpm -qa | grep nfs-utils
   {% else %}
    - name: nfs-common
    - unless: dpkg -l | grep nfs-common
   {% endif %}

write_fstab:
  cmd.run:
    - name: echo "{{ pillar['inet-ip'] }}:/grdata /grdata nfs rw 0 0" >> /etc/fstab
    - unless: grep "/grdata" /etc/fstab

automount:
    cmd.run:
      - name: mount /grdata
      - unless: ls /grdata/services


    