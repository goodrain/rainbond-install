{% if pillar['install-type'] == "online" and grains['os_family']|lower == 'redhat' %}
container-selinux-remove:
    cmd.run: 
        - name: yum remove -y container-selinux
        - onlyif: rpm -q container-selinux
{% endif %}
common_packages:
  pkg.installed:
    - pkgs:
      - iotop
      - nload
      - telnet
      - htop
      - lsof
      - tree
      - rsync
      - lvm2
