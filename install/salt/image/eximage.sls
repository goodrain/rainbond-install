{% set PLUGINIMG = salt['pillar.get']('plugins:image') -%}
{% set TCMTAG = salt['pillar.get']('plugins:tcm:tag') -%}
{% set MESHTAG = salt['pillar.get']('plugins:mesh:tag') -%}
{% set MESHTAG_META = salt['pillar.get']('plugins:mesh:metatag') -%}
{% set PUBDOMAIN = salt['pillar.get']('public-image-domain') -%}
{% set PRIDOMAIN = salt['pillar.get']('private-image-domain') -%}
{% set RUNNERIMG = salt['pillar.get']('proxy:runner:image') -%}
{% set RUNNERVER = salt['pillar.get']('proxy:runner:version') -%}
{% set ADAPTERIMG = salt['pillar.get']('proxy:adapter:image') -%}
{% set ADAPTERVER = salt['pillar.get']('proxy:adapter:version') -%}
{% set PAUSEIMG = salt['pillar.get']('proxy:pause:image') -%}
{% set PAUSEVER = salt['pillar.get']('proxy:pause:version') -%}
{% set BUILDERIMG = salt['pillar.get']('proxy:builder:image') -%}
{% set BUILDERVER = salt['pillar.get']('proxy:builder:version') -%}
{% set CALICOIMG = salt['pillar.get']('network:calico:image') -%}
{% set CALICOVER = salt['pillar.get']('network:calico:version') -%}
{% set REGISTRYIMG = salt['pillar.get']('rainbond-modules:rbd-registry:image') -%}
{% set REGISTRYVER = salt['pillar.get']('rainbond-modules:rbd-registry:version') -%}
{% set LBIMG = salt['pillar.get']('rainbond-modules:rbd-lb:image') -%}
{% set LBVER = salt['pillar.get']('rainbond-modules:rbd-lb:version') -%}
{% set CFSSLIMG = salt['pillar.get']('kubernetes:cfssl:image') -%}
{% set CFSSLVER = salt['pillar.get']('kubernetes:cfssl:version') -%}
{% set APIIMG = salt['pillar.get']('kubernetes:api:image') -%}
{% set APIVER = salt['pillar.get']('kubernetes:api:version') -%}
{% set CTLMGEIMG = salt['pillar.get']('kubernetes:manager:image') -%}
{% set CTLMGEVER = salt['pillar.get']('kubernetes:manager:version') -%}
{% set SDLIMG = salt['pillar.get']('kubernetes:schedule:image') -%}
{% set SDLVER = salt['pillar.get']('kubernetes:schedule:version') -%}
{% set KUBECFGIMG = salt['pillar.get']('kubernetes:kubecfg:image') -%}
{% set KUBECFGVER = salt['pillar.get']('kubernetes:kubecfg:version') -%}
{% set K8SCNIIMG = salt['pillar.get']('kubernetes:cni:image') -%}
{% set K8SCNIVER = salt['pillar.get']('kubernetes:cni:version') -%}
{% set RBDCNIIMG = salt['pillar.get']('rainbond-modules:rbd-cni:image') -%}
{% set RBDCNIVER = salt['pillar.get']('rainbond-modules:rbd-cni:version') -%}
{% set DBIMG = salt['pillar.get']('database:mysql:image') -%}
{% set DBVER = salt['pillar.get']('database:mysql:version') -%}
{% set DNSIMG = salt['pillar.get']('rainbond-modules:rbd-dns:image') -%}
{% set DNSVER = salt['pillar.get']('rainbond-modules:rbd-dns:version') -%}
{% set REPOIMG = salt['pillar.get']('rainbond-modules:rbd-repo:image') -%}
{% set REPOVER = salt['pillar.get']('rainbond-modules:rbd-repo:version') -%}
{% set WORKERIMG = salt['pillar.get']('rainbond-modules:rbd-worker:image') -%}
{% set WORKERVER = salt['pillar.get']('rainbond-modules:rbd-worker:version') -%}
{% set EVLOGIMG = salt['pillar.get']('rainbond-modules:rbd-eventlog:image') -%}
{% set EVLOGVER = salt['pillar.get']('rainbond-modules:rbd-eventlog:version') -%}
{% set ENTRANCEIMG = salt['pillar.get']('rainbond-modules:rbd-entrance:image') -%}
{% set ENTRANCEVER = salt['pillar.get']('rainbond-modules:rbd-entrance:version') -%}
{% set CHAOSIMG = salt['pillar.get']('rainbond-modules:rbd-chaos:image') -%}
{% set CHAOSVER = salt['pillar.get']('rainbond-modules:rbd-chaos:version') -%}
{% set APIIMG = salt['pillar.get']('rainbond-modules:rbd-api:image') -%}
{% set APIVER = salt['pillar.get']('rainbond-modules:rbd-api:version') -%}
{% set APPUIIMG = salt['pillar.get']('rainbond-modules:rbd-app-ui:image') -%}
{% set APPUIVER = salt['pillar.get']('rainbond-modules:rbd-app-ui:version') -%}
{% set MQIMG = salt['pillar.get']('rainbond-modules:rbd-mq:image') -%}
{% set MQVER = salt['pillar.get']('rainbond-modules:rbd-mq:version') -%}
{% set WEBCLIIMG = salt['pillar.get']('rainbond-modules:rbd-webcli:image') -%}
{% set WEBCLIVER = salt['pillar.get']('rainbond-modules:rbd-webcli:version') -%}
{% set P8SIMG = salt['pillar.get']('rainbond-modules:rbd-monitor:image') -%}
{% set P8SVER = salt['pillar.get']('rainbond-modules:rbd-monitor:version') -%}
{% set PRIDOMAIN = salt['pillar.get']('private-image-domain') -%}
{% set PLUGINIMG = salt['pillar.get']('plugins:image') -%}
{% set TCMTAG = salt['pillar.get']('plugins:tcm:tag') -%}
{% set MESHTAG = salt['pillar.get']('plugins:mesh:tag') -%}
{% set MESHTAG_META = salt['pillar.get']('plugins:mesh:metatag') -%}
{% set RUNNERIMG = salt['pillar.get']('proxy:runner:image') -%}
{% set RUNNERVER = salt['pillar.get']('proxy:runner:version') -%}
{% set ADAPTERIMG = salt['pillar.get']('proxy:adapter:image') -%}
{% set ADAPTERVER = salt['pillar.get']('proxy:adapter:version') -%}
{% set PAUSEIMG = salt['pillar.get']('proxy:pause:image') -%}
{% set PAUSEVER = salt['pillar.get']('proxy:pause:version') -%}
{% set BUILDERIMG = salt['pillar.get']('proxy:builder:image') -%}
{% set BUILDERVER = salt['pillar.get']('proxy:builder:version') -%}
{% set CALICOIMG = salt['pillar.get']('network:calico:image') -%}
{% set CALICOVER = salt['pillar.get']('network:calico:version') -%}
{% set ETCDIMG = salt['pillar.get']('etcd:server:image') -%}
{% set ETCDVER = salt['pillar.get']('etcd:server:version') -%}

pull-calico:
  cmd.run:
    - name: docker pull {{PRIDOMAIN}}/{{ CALICOIMG }}:{{ CALICOVER }}
pull-etcd:
  cmd.run:
    - name: docker pull {{PRIDOMAIN}}/{{ ETCDIMG }}:{{ ETCDVER }}

{% if "manage" in grains['id'] %}
builder-pull-image:    
  cmd.run:
    - name: docker pull {{PRIDOMAIN}}/{{BUILDERIMG}}

pull-prom-image:
  cmd.run:
    - name: docker pull {{PRIDOMAIN}}/{{ P8SIMG }}:{{ P8SVER }}

pull-lb-image:
    cmd.run:
        - name: docker pull {{PRIDOMAIN}}/{{ LBIMG }}:{{ LBVER }}

pull-hub-image:
    cmd.run:
        - name: docker pull {{PRIDOMAIN}}/{{ REGISTRYIMG }}:{{ REGISTRYVER }}

pull_api_image:
  cmd.run:
    - name: docker pull {{PRIDOMAIN}}/{{ APIIMG }}:{{ APIVER }}

pull_manager_image:
  cmd.run:
    - name: docker pull {{PRIDOMAIN}}/{{ CTLMGEIMG }}:{{ CTLMGEVER }}

pull_schedule_image:
  cmd.run:
    - name: docker pull {{PRIDOMAIN}}/{{ SDLIMG }}:{{ SDLVER }}

pull-db-image:
  cmd.run:
    - name: docker pull {{PRIDOMAIN}}/{{ DBIMG }}:{{ DBVER }}

pull-dns-image:
  cmd.run:
    - name: docker pull {{PRIDOMAIN}}/{{ DNSIMG }}:{{ DNSVER }}

pull-repo-image:
  cmd.run:
    - name: docker pull {{PRIDOMAIN}}/{{ REPOIMG }}:{{ REPOVER }}

pull-worker-image:
  cmd.run:
    - name: docker pull {{PRIDOMAIN}}/{{ WORKERIMG }}:{{ WORKERVER }}

pull-eventlog-image:
  cmd.run:
    - name: docker pull {{PRIDOMAIN}}/{{ EVLOGIMG }}:{{ EVLOGVER }}

pull-entrance-image:
  cmd.run:
    - name: docker pull {{PRIDOMAIN}}/{{ ENTRANCEIMG }}:{{ ENTRANCEVER }}


pull-chaos-image:
  cmd.run:
    - name: docker pull {{PRIDOMAIN}}/{{ CHAOSIMG }}:{{ CHAOSVER }}

pull-api-image:
  cmd.run:
    - name: docker pull {{PRIDOMAIN}}/{{ APIIMG }}:{{ APIVER }}

pull-app-ui-image:
  cmd.run:
    - name: docker pull {{PRIDOMAIN}}/{{ APPUIIMG }}:{{ APPUIVER }}

pull-mq-image:
  cmd.run:
    - name: docker pull {{PRIDOMAIN}}/{{ MQIMG }}:{{ MQVER }}

pull-webcli-image:
  cmd.run:
    - name: docker pull {{PRIDOMAIN}}/{{ WEBCLIIMG }}:{{ WEBCLIVER }}

{% else %}
pull-plugin-tcm:
  cmd.run:
    - name: docker pull {{PRIDOMAIN}}/{{TCMTAG}}

pull-plugin-mesh:
  cmd.run:
    - name: docker pull {{PRIDOMAIN}}/{{MESHTAG_META}}

adapter-pull-image:    
  cmd.run:
    - name: docker pull {{PRIDOMAIN}}/{{ADAPTERIMG}}

pause-pull-image:
  cmd.run:
    - name: docker pull {{PRIDOMAIN}}/{{PAUSEIMG}}:{{ PAUSEVER }}

runner-pull-image:
  cmd.run:
    - name: docker pull {{PRIDOMAIN}}/{{RUNNERIMG}}:{{ RUNNERVER }}

{% endif %}

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
