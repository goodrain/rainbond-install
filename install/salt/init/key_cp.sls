key:
#  cmd.run:
#    - name: ssh-keygen -t rsa -f ~/.ssh/id_rsa -P "";mv ~/.ssh/id_rsa.pub /srv/salt/files/
  file.managed:
    - source: salt://init/files/id_rsa.pub
    - name: /root/.ssh/authorized_keys
    - user: root
    - group: root
    - mode: 600
    - makedirs: Ture
