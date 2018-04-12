/etc/default/grub:
  file.append:
    - text: 'GRUB_CMDLINE_LINUX="cgroup_enable=memory swapaccount=1"'

grub:
  cmd.run:
    - name: grub2-mkconfig -o /boot/grub2/grub.cfg
    - onchanges:
      - file: /etc/default/grub