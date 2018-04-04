{% set path = pillar['rbd-path'] %}

{% if grains['host']  == 'manage01' %}
key_echo:
  cmd.run:
    - name: cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys
{% else %}
key_cp:
  file.managed:
    - source: salt://init/files/id_rsa.pub
    - name: /tmp/id_rsa.pub
    - user: root
    - group: root
    - mode: 600
    - makedirs: Ture
    - unless: test -f /tmp/id_rsa.pub
  cmd.run:
    - name: cat /tmp/id_rsa.pub >> /root/.ssh/authorized_keys
{% endif %}

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

key_config:
  file.managed:
    - source: salt://init/files/config
    - name: {{ path }}/etc/rbd-chaos/ssh/config
    - user: root
    - group: root
    - mode: 600
    - makedirs: Ture
    
