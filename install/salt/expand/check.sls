before_install:
  file.managed:
    - name: /tmp/before_install.sh
    - source: salt://expand/scripts/before_install.sh
    - user: root
    - group: root
    - mode: 644
check:
  cmd.run:
    - name: bash /tmp/before_install.sh