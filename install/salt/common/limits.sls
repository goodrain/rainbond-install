/etc/security/limits.conf:
  file.append:
    - text:
      - "root soft nofile 102400"
      - "root hard nofile 102400"
      - "* soft nofile 102400"
      - "* hard nofile 102400"
      - "* soft memlock unlimited"
      - "* hard memlock unlimited"
      - "* soft nproc 2048"
      - "* hard nproc 4096"

vm.max_map_count:
  sysctl.present:
    - value: 262144

net.ipv4.ip_forward:
  sysctl.present:
    - value: 1