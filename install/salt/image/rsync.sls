rsync-region-ssl:
  file.recurse:
    - source: salt://install/files/ssl/region
    - name: {{ pillar['rbd-path'] }}/etc/rbd-api/region.goodrain.me/ssl
    - clean: True

config-grctl-yaml:
  file.managed:
    - source: salt://install/files/grctl/config.yaml
    - name: /root/.rbd/grctl.yaml
    - makedirs: True
    - template: jinja

