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

default_http_conf:
  file.managed:
    - source: salt://install/files/plugins/proxy.conf
    - name: {{ pillar['rbd-path'] }}/etc/rbd-lb/dynamics/dynamic_servers/default.http.conf
    - template: jinja
    - makedirs: True

proxy_site_ssl:
  file.recurse:
    - source: salt://install/files/ssl/goodrain.me
    - name: {{ pillar['rbd-path'] }}/etc/rbd-lb/dynamics/dynamic_certs/goodrain.me
    - makedirs: True

proxy_lb_init:
  file.managed:
    - source: salt://install/files/plugins/init-lb.sh
    - name: {{ pillar['rbd-path'] }}/scripts/init-lb.sh
    - mode: 755
    - template: jinja
    - makedirs: True