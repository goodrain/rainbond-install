/usr/bin/cclear:
  file.managed:
    - source: salt://install/files/init/bin/cclear
    - user: root
    - group: root
    - mode: 755

/usr/bin/checkdns:
  file.managed:
    - source: salt://install/files/init/bin/checkdns
    - user: root
    - group: root
    - mode: 755

/usr/bin/grclis:
  file.managed:
    - source: salt://install/files/init/bin/grclis
    - user: root
    - group: root
    - mode: 755

/usr/bin/din:
  file.managed:
    - source: salt://install/files/init/bin/din
    - user: root
    - group: root
    - mode: 755


/usr/bin/dps:
  file.managed:
    - source: salt://install/files/init/bin/dps
    - user: root
    - group: root
    - mode: 755

/usr/bin/iclear:
  file.managed:
    - source: salt://install/files/init/bin/iclear
    - user: root
    - group: root
    - mode: 755

/usr/bin/igrep:
  file.managed:
    - source: salt://install/files/init/bin/igrep
    - user: root
    - group: root
    - mode: 755

/usr/bin/vclear:
  file.managed:
    - source: salt://install/files/init/bin/vclear
    - user: root
    - group: root
    - mode: 755

/usr/bin/check_compose:
  file.managed:
    - source: salt://install/files/init/bin/check_compose
    - user: root
    - group: root
    - mode: 755
 
/usr/local/bin/dc-compose:
  file.managed:
    - source: salt://install/files/init/bin/dc-compose
    - makedirs: Ture
    - template: jinja
    - user: root
    - group: root
    - mode: 755 