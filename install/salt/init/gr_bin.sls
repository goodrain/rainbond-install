/usr/bin/cclear:
  file.managed:
    - source: salt://init/files/bin/cclear
    - user: root
    - group: root
    - mode: 755

/usr/bin/checkdns:
  file.managed:
    - source: salt://init/files/bin/checkdns
    - user: root
    - group: root
    - mode: 755

/usr/bin/din:
  file.managed:
    - source: salt://init/files/bin/din
    - user: root
    - group: root
    - mode: 755


/usr/bin/dps:
  file.managed:
    - source: salt://init/files/bin/dps
    - user: root
    - group: root
    - mode: 755

/usr/bin/iclear:
  file.managed:
    - source: salt://init/files/bin/iclear
    - user: root
    - group: root
    - mode: 755

/usr/bin/igrep:
  file.managed:
    - source: salt://init/files/bin/igrep
    - user: root
    - group: root
    - mode: 755

/usr/bin/vclear:
  file.managed:
    - source: salt://init/files/bin/vclear
    - user: root
    - group: root
    - mode: 755

/usr/bin/check_compose:
  file.managed:
    - source: salt://init/files/bin/check_compose
    - user: root
    - group: root
    - mode: 755