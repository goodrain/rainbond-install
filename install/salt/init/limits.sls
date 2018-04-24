/etc/security/limits.conf:
  file.append:
    - text:
      - "root soft nofile 102400"
      - "root hard nofile 102400"
      - "* soft nofile 102400"
      - "* hard nofile 102400"
      - "* soft memlock unlimited"
      - "* hard memlock unlimited"
