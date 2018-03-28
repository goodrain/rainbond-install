{% set path = pillar['rbd_path'] %}
key_cp :
  file.managed:
    - source: salt://init/files/id_rsa.pub
    - name: /root/.ssh/authorized_keys
    - user: root
    - group: root
    - mode: 600
    - makedirs: Ture

key_rsa_ssh:
  file.managed:
    - source: salt://init/files/id_rsa
    - name: {{ path }}/etc/rbd-chaos/ssh/id_rsa
    - user: root
    - group: root
    - mode: 600
    - makedirs: Ture

key_rsa_buider:
  file.managed:
    - source: salt://init/files/id_rsa
    - name: {{ path }}/etc/rbd-chaos/ssh/builder_rsa
    - user: root
    - group: root
    - mode: 600
    - makedirs: Ture

key_pub_ssh:
  file.managed:
    - source: salt://init/files/id_rsa.pub
    - name: {{ path }}/etc/rbd-chaos/ssh/id_rsa.pub
    - user: root
    - group: root
    - mode: 600
    - makedirs: Ture


key_pub_builder:
  file.managed:
    - source: salt://init/files/id_rsa.pub
    - name: {{ path }}/etc/rbd-chaos/ssh/builder_rsa.pub
    - user: root
    - group: root
    - mode: 600
    - makedirs: Ture
