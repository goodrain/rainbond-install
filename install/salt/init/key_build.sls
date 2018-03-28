{% set path = pillar['intsall-script-path'] %}
key_rsa:
  cmd.run:
     - name: ssh-keygen -t rsa -f ~/.ssh/id_rsa -P "" ;cp -a ~/.ssh/id_rsa {{ path }}/rainbond-install/install/salt/init/files
key_pub:
  cmd.run:
     - name: cp -a ~/.ssh/id_rsa.pub {{ path }}/rainbond-install/install/salt/init/files
