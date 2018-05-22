{% set PLUGTCMIMG = salt['pillar.get']('proxy:plugins:image') -%}
{% set PLUGTCMVER = salt['pillar.get']('proxy:plugins:version') -%}

docker-pull-plugins:
  cmd.run:
    - name: docker pull {{ PLUGTCMIMG }}:{{ PLUGTCMVER }}
    - unless: docker inspect {{ PLUGTCMIMG }}:{{ PLUGTCMVER }}
    
plugins-tag:
  cmd.run:
    - name: docker tag {{ PLUGTCMIMG }}:{{ PLUGTCMVER }} goodrain.me/{{ PLUGTCMVER }}
    - unless: docker inspect goodrain.me/{{ PLUGTCMVER }}
    - require:
      - cmd: docker-pull-plugins

plugins-push:
  cmd.run:
    - name: docker push goodrain.me/{{ PLUGTCMVER }}
    - require:
      - cmd: plugins-tag