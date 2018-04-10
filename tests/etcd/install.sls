# -*- coding: utf-8 -*-
# vim: ft=yaml

{% from "etcd/map.jinja" import etcd_settings,systemd with context -%}

{% set etcd_name = "etcd-v" + etcd_settings.install.version + "-linux-amd64" -%}
{% set etcd_archive_name = etcd_name + ".tar.gz" -%}
{% set etcd_package_url = "v" + etcd_settings.install.version + "/" + etcd_archive_name -%}

etcd-directory:
  file.directory:
    - name: {{ etcd_settings.binary_directory }}
    - makedirs: True

etcd-data-directory:
  file.directory:
    - name: {{ etcd_settings.data_directory }}
    - makedirs: True

etcd-download:
  cmd.run:
    - name: curl -L -s {{ etcd_settings.install.base_url }}/{{ etcd_package_url }} -o {{ etcd_archive_name }}
    - cwd: {{ etcd_settings.binary_directory }}
    - unless: test -f {{ etcd_settings.binary_directory }}/{{ etcd_archive_name }}

etcd-extract:
  cmd.run:
    - name: tar xzf {{ etcd_archive_name }} --strip-components 1
    - cwd: {{ etcd_settings.binary_directory }}
    - unless: test -f etcd

{% if systemd -%}
etcd-systemd-file:
  file.managed:
    - name: /etc/systemd/system/etcd.service
    - source: salt://etcd/files/etcd.service.jinja
    - user: root
    - group: root
    - mode: 0644
    - template: jinja
    - watch_in:
        service: etcd-service
{% else -%}
etcd-upstart-file:
  file.managed:
    - name: /etc/init/etcd.conf
    - source: salt://etcd/files/etcd.conf.jinja
    - user: root
    - group: root
    - mode: 0644
    - template: jinja
    - watch_in:
        service: etcd-service
{% endif -%}

etcd-service:
  service.running:
    - name: etcd

