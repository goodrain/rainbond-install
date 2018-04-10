create_host_uuid:
  file.managed:
    - source: salt://init/files/host_id_list.conf
    - name: {{ pillar['rbd-path'] }}/etc/api/host_id_list.conf
    - makedirs: Ture
    - template: jinja