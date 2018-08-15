{% if "manage" in grains['id'] %}
{% if grains['id'] == 'manage01' %}
{% set sslpath = "/srv/salt/install/files/ssl/region" %}
region-ssl-ca:
  cmd.run:
    - name: grcert create --is-ca --ca-name={{ sslpath }}/ca.pem --ca-key-name={{ sslpath }}/ca.key.pem
    - unless: ls -l {{ sslpath }}/ca.pem

region-server-ssl:
  cmd.run:
    - name: grcert create --ca-name={{ sslpath }}/ca.pem --ca-key-name={{ sslpath }}/ca.key.pem --crt-name={{ sslpath }}/server.pem --crt-key-name={{ sslpath }}/server.key.pem --domains region.goodrain.me --address={{ pillar['vip'] }} --address=127.0.0.1
    - unless: ls -l {{ sslpath }}/server.pem

region-client-ssl:
  cmd.run:
    - name: grcert create --ca-name={{ sslpath }}/ca.pem --ca-key-name={{ sslpath }}/ca.key.pem --crt-name={{ sslpath }}/client.pem --crt-key-name={{ sslpath }}/client.key.pem --domains region.goodrain.me --address={{ pillar['vip'] }} --address=127.0.0.1
    - unless: ls -l {{ sslpath }}/client.pem
{% endif %}
{% endif %}