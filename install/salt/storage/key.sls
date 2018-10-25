key_rsa_ssh:
  file.managed:
    - source: salt://install/files/key/id_rsa
    - name: /grdata/services/ssh/id_rsa
    - user: root
    - group: root
    - mode: 600
    - makedirs: True

key_rsa_buider:
  file.managed:
    - source: salt://install/files/key/id_rsa
    - name: /grdata/services/ssh/builder_rsa
    - user: root
    - group: root
    - mode: 600
    - makedirs: True

key_pub_ssh:
  file.managed:
    - source: salt://install/files/key/id_rsa.pub
    - name: /grdata/services/ssh/id_rsa.pub
    - user: root
    - group: root
    - mode: 600
    - makedirs: True

key_pub_builder:
  file.managed:
    - source: salt://install/files/key/id_rsa.pub
    - name: /grdata/services/ssh/builder_rsa.pub
    - user: root
    - group: root
    - mode: 600
    - makedirs: True

key_config:
  file.managed:
    - source: salt://install/files/key/config
    - name: /grdata/services/ssh/config
    - user: root
    - group: root
    - mode: 600
    - makedirs: True