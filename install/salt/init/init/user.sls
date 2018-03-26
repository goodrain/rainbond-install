rain:
  user.present:
    - fullname: rain
    - shell: /bin/bash
    - home: /home/rain
    - uid: 200
    - gid: 200
    - groups:
      - rain
    - require:
      - group: rain

  group.present:
    - gid: 200
