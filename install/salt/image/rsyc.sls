rsync-region-ssl:
  file.recurse:
    - source: salt://install/files/ssl/region.goodain.me
    - name: {{ pillar['rbd-path'] }}/etc/rbd-api/region.goodrain.me/ssl
    - makedirs: True

config-grctl-yaml:
  file.managed:
    - source: salt://install/files/grctl/config.yaml
    - name: /root/.rbd/grctl.yaml
    - makedirs: True
    - template: jinja