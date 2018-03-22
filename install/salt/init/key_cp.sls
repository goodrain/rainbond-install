key:
  file.managed:
    - source: salt://init/files/id_rsa.pub
    - name: /root/.ssh/authorized_keys
    - user: root
    - group: root
    - mode: 600
    - makedirs: Ture
