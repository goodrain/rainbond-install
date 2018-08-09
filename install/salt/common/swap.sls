/etc/default/grub:
  file.append:
    - text: 'GRUB_CMDLINE_LINUX="cgroup_enable=memory swapaccount=1"'

grub:
  cmd.run:
  {% if grains['os_family']|lower == 'redhat' %}
    - name: grub2-mkconfig -o /boot/grub2/grub.cfg
  {% else %}
    - name: grub-mkconfig -o /boot/grub/grub.cfg
  {% endif %}
    - onchanges:
      - file: /etc/default/grub