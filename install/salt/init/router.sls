/etc/sysctl.conf:
  file.append:
    - text: 'net.ipv4.ip_forward=1'
