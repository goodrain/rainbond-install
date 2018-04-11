# -*- coding: utf-8 -*-
# vim: ft=yaml

{% from "etcd/map.jinja" import etcd_settings with context %}

python-etcd:
  pip.installed

etcd-salt-conf:
  file.managed:
    - name: /etc/salt/master.d/etcd.conf
    - source: salt://etcd/files/salt/etcd.conf.static.jinja
    - template: jinja

#restart salt master

