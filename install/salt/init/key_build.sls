{% set path = pillar['install-script-path'] %}
key_build:
  cmd.run:
     - name: ssh-keygen -t rsa -f ~/.ssh/id_rsa -P ""
     - unless: test -f ~/.ssh/id_rsa.pub
key_rsa:
  cmd.run:
     - name: cp -a ~/.ssh/id_rsa /srv/salt/init/files
key_pub:
  cmd.run:
     - name: cp -a ~/.ssh/id_rsa.pub /srv/salt/init/files
