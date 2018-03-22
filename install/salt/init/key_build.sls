{% set path = pillar['rbd_path'] %}
key:
  cmd.run:
     - name: ssh-keygen -t rsa -f ~/.ssh/id_rsa -P "" ;cp -a ~/.ssh/id_rsa.pub {{ path }}/intsall/salt/init/files
