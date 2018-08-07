#====================== type ========================================
{% set PRIDOMAIN = salt['pillar.get']('private-image-domain') -%}
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
{% set GRAFANA = salt['pillar.get']('rainbond-modules:rbd-grafana:version') -%}

docker-load-lb-image:
  cmd.run:
    - name: docker load -i {{ pillar['rbd-path'] }}/install/install/imgs/goodrainme_{{ LBIMG }}_{{ LBVER }}.gz

docker-load-hub-image:
  cmd.run:
    - name: docker load -i {{ pillar['rbd-path'] }}/install/install/imgs/goodrainme_{{ REGISTRYIMG }}_{{ REGISTRYVER }}.gz

upstart-lb:
  cmd.run:
    - name: dc-compose up -d rbd-lb
    - unless: docker ps | grep lb

upstart-hub:
  cmd.run:
    - name: dc-compose up -d rbd-hub
    - unless: docker ps | grep hub

push-lb-image:
  cmd.run:
    - name: docker push {{PRIDOMAIN}}/{{ LBIMG }}:{{ LBVER }}

push-hub-image:
  cmd.run:
    - name: docker push {{PRIDOMAIN}}/{{ REGISTRYIMG }}:{{ REGISTRYVER }}

#===================== k8s image =================================
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


load_api_image:
  cmd.run:
    - name: docker load -i {{ pillar['rbd-path'] }}/install/install/imgs/goodrainme_{{ APIIMG }}_{{ APIVER }}.gz

push_api_image:
  cmd.run:
    - name: docker push {{PRIDOMAIN}}/{{ APIIMG }}:{{ APIVER }}



load_manager_image:
  cmd.run:
    - name:  docker load -i {{ pillar['rbd-path'] }}/install/install/imgs/goodrainme_{{ CTLMGEIMG }}_{{ APIVER }}.gz

push_manager_image:
  cmd.run:
    - name: docker push {{PRIDOMAIN}}/{{ CTLMGEIMG }}:{{ APIVER }}


load_schedule_image:
  cmd.run:
    - name:  docker load -i {{ pillar['rbd-path'] }}/install/install/imgs/goodrainme_{{ SDLIMG }}_{{ SDLVER }}.gz

push_schedule_image:
  cmd.run:
    - name: docker push {{PRIDOMAIN}}/{{ SDLIMG }}:{{ SDLVER }}

#===================== etcd image ================================
{% set ETCDIMG = salt['pillar.get']('etcd:server:image') -%}
{% set ETCDVER = salt['pillar.get']('etcd:server:version') -%}

load_etcd_image:
  cmd.run:
    - name:  docker load -i {{ pillar['rbd-path'] }}/install/install/imgs/goodrainme_{{ ETCDIMG }}_{{ ETCDVER }}.gz

push_etcd_image:
  cmd.run:
    - name: docker push {{PRIDOMAIN}}/{{ ETCDIMG }}:{{ ETCDVER }}

#===================== network image =============================
{% set CALICOIMG = salt['pillar.get']('network:calico:image') -%}
{% set CALICOVER = salt['pillar.get']('network:calico:version') -%}


load-calico-image:
  cmd.run:
    - name:  docker load -i {{ pillar['rbd-path'] }}/install/install/imgs/goodrainme_{{ CALICOIMG }}_{{ CALICOVER }}.gz

push-calico-image:
  cmd.run:
    - name: docker push {{PRIDOMAIN}}/{{ CALICOIMG }}:{{ CALICOVER }}

#===================== db image ==================================
{% set DBIMG = salt['pillar.get']('database:mysql:image') -%}
{% set DBVER = salt['pillar.get']('database:mysql:version') -%}


load-db-image:
  cmd.run:
    - name:  docker load -i {{ pillar['rbd-path'] }}/install/install/imgs/goodrainme_{{ DBIMG }}_{{ DBVER }}.gz

push-db-image:
  cmd.run:
    - name: docker push {{PRIDOMAIN}}/{{ DBIMG }}:{{ DBVER }}
#===================== base image ================================


{% set DNSIMG = salt['pillar.get']('rainbond-modules:rbd-dns:image') -%}
{% set DNSVER = salt['pillar.get']('rainbond-modules:rbd-dns:version') -%}
load-pull-dns-image:
  cmd.run:
    - name:  docker load -i {{ pillar['rbd-path'] }}/install/install/imgs/goodrainme_{{ DNSIMG }}_{{ DNSVER }}.gz

push-dns-image:
  cmd.run:
    - name: docker push {{PRIDOMAIN}}/{{ DNSIMG }}:{{ DNSVER }}

{% set REPOIMG = salt['pillar.get']('rainbond-modules:rbd-repo:image') -%}
{% set REPOVER = salt['pillar.get']('rainbond-modules:rbd-repo:version') -%}
load-pull-repo-image:
  cmd.run:
    - name:  docker load -i {{ pillar['rbd-path'] }}/install/install/imgs/goodrainme_{{ REPOIMG }}_{{ REPOVER }}.gz

push-repo-image:
  cmd.run:
    - name: docker push {{PRIDOMAIN}}/{{ REPOIMG }}:{{ REPOVER }}

#===================== plugin image ==============================

{% set WORKERIMG = salt['pillar.get']('rainbond-modules:rbd-worker:image') -%}
{% set WORKERVER = salt['pillar.get']('rainbond-modules:rbd-worker:version') -%}
load-pull-worker-image:
  cmd.run:
    - name:  docker load -i {{ pillar['rbd-path'] }}/install/install/imgs/goodrainme_{{ WORKERIMG }}_{{ WORKERVER }}.gz

push-worker-image:
  cmd.run:
    - name: docker push {{PRIDOMAIN}}/{{ WORKERIMG }}:{{ WORKERVER }}

{% set EVLOGIMG = salt['pillar.get']('rainbond-modules:rbd-eventlog:image') -%}
{% set EVLOGVER = salt['pillar.get']('rainbond-modules:rbd-eventlog:version') -%}
load-pull-eventlog-image:
  cmd.run:
    - name: docker load -i {{ pillar['rbd-path'] }}/install/install/imgs/goodrainme_{{ EVLOGIMG }}_{{ EVLOGVER }}.gz

push-eventlog-image:
  cmd.run:
    - name: docker push {{PRIDOMAIN}}/{{ EVLOGIMG }}:{{ EVLOGVER }}

{% set ENTRANCEIMG = salt['pillar.get']('rainbond-modules:rbd-entrance:image') -%}
{% set ENTRANCEVER = salt['pillar.get']('rainbond-modules:rbd-entrance:version') -%}
load-pull-entrance-image:
  cmd.run:
    - name: docker load -i {{ pillar['rbd-path'] }}/install/install/imgs/goodrainme_{{ ENTRANCEIMG }}_{{ ENTRANCEVER }}.gz

push-entrance-image:
  cmd.run:
    - name: docker push {{PRIDOMAIN}}/{{ ENTRANCEIMG }}:{{ ENTRANCEVER }}

{% set CHAOSIMG = salt['pillar.get']('rainbond-modules:rbd-chaos:image') -%}
{% set CHAOSVER = salt['pillar.get']('rainbond-modules:rbd-chaos:version') -%}
load-pull-chaos-image:
  cmd.run:
    - name: docker load -i {{ pillar['rbd-path'] }}/install/install/imgs/goodrainme_{{ CHAOSIMG }}_{{ CHAOSVER }}.gz

push-chaos-image:
  cmd.run:
    - name: docker push {{PRIDOMAIN}}/{{ CHAOSIMG }}:{{ CHAOSVER }}


{% set APIIMG = salt['pillar.get']('rainbond-modules:rbd-api:image') -%}
{% set APIVER = salt['pillar.get']('rainbond-modules:rbd-api:version') -%}
load-pull-api-image:
  cmd.run:
    - name: docker load -i {{ pillar['rbd-path'] }}/install/install/imgs/goodrainme_{{ APIIMG }}_{{ APIVER }}.gz

push-api-image:
  cmd.run:
    - name: docker push {{PRIDOMAIN}}/{{ APIIMG }}:{{ APIVER }}

{% set APPUIIMG = salt['pillar.get']('rainbond-modules:rbd-app-ui:image') -%}
{% set APPUIVER = salt['pillar.get']('rainbond-modules:rbd-app-ui:version') -%}
load-pull-app-ui-image:
  cmd.run:
    - name: docker load -i {{ pillar['rbd-path'] }}/install/install/imgs/goodrainme_{{ APPUIIMG }}_{{ APPUIVER }}.gz

push-app-ui-image:
  cmd.run:
    - name: docker push {{PRIDOMAIN}}/{{ APPUIIMG }}:{{ APPUIVER }}

{% set MQIMG = salt['pillar.get']('rainbond-modules:rbd-mq:image') -%}
{% set MQVER = salt['pillar.get']('rainbond-modules:rbd-mq:version') -%}
load-pull-mq-image:
  cmd.run:
    - name: docker load -i {{ pillar['rbd-path'] }}/install/install/imgs/goodrainme_{{ MQIMG }}_{{ MQVER }}.gz

push-mq-image:
  cmd.run:
    - name: docker push {{PRIDOMAIN}}/{{ MQIMG }}:{{ MQVER }}


{% set WEBCLIIMG = salt['pillar.get']('rainbond-modules:rbd-webcli:image') -%}
{% set WEBCLIVER = salt['pillar.get']('rainbond-modules:rbd-webcli:version') -%}
load-pull-webcli-image:
  cmd.run:
    - name: docker load -i {{ pillar['rbd-path'] }}/install/install/imgs/goodrainme_{{ WEBCLIIMG }}_{{ WEBCLIVER }}.gz

push-webcli-image:
  cmd.run:
    - name: docker push {{PRIDOMAIN}}/{{ WEBCLIIMG }}:{{ WEBCLIVER }}


{% set P8SIMG = salt['pillar.get']('rainbond-modules:rbd-monitor:image') -%}
{% set P8SVER = salt['pillar.get']('rainbond-modules:rbd-monitor:version') -%}
load-pull-prom-image:
  cmd.run:
    - name: docker load -i {{ pillar['rbd-path'] }}/install/install/imgs/goodrainme_{{ P8SIMG }}_{{ P8SVER }}.gz

push-prom-image:
  cmd.run:
    - name: docker push {{PRIDOMAIN}}/{{ P8SIMG }}:{{ P8SVER }}

load-grafana-tcm:
  cmd.run:
    - name: docker load -i {{ pillar['rbd-path'] }}/install/install/imgs/goodrainme_grafana_{{GRAFANA}}.gz

#===================== builder/runner image ===========================
runner-load:
  cmd.run:
    - name: docker load -i {{ pillar['rbd-path'] }}/install/install/imgs/goodrainme_{{RUNNERIMG}}_{{ RUNNERVER }}.gz

adapter-load:
  cmd.run:
    - name: docker load -i {{ pillar['rbd-path'] }}/install/install/imgs/goodrainme_{{ADAPTERIMG}}_{{ ADAPTERVER }}.gz

pause-load:
  cmd.run:
    - name: docker load -i {{ pillar['rbd-path'] }}/install/install/imgs/goodrainme_{{PAUSEIMG}}_{{ PAUSEVER }}.gz

builder-load:  
  cmd.run:
    - name: docker load -i {{ pillar['rbd-path'] }}/install/install/imgs/goodrainme_{{BUILDERIMG}}_{{BUILDERVER}}.gz

#===================== addons image ==============================


load-plugin-tcm:
  cmd.run:
    - name: docker load -i {{ pillar['rbd-path'] }}/install/install/imgs/goodrainme_plugins_tcm.gz

tcm-rename:
  cmd.run:
    - name: docker tag goodrain.me/plugins:tcm goodrain.me/tcm

load-plugin-mesh:
  cmd.run:
    - name: docker load -i {{ pillar['rbd-path'] }}/install/install/imgs/goodrainme_plugins_mesh.gz

mesh-rename:
  cmd.run:
    - name: docker tag goodrain.me/plugins:mesh goodrain.me/mesh_plugin

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
{% set ETCDIMG = salt['pillar.get']('etcd:server:image') -%}
{% set ETCDVER = salt['pillar.get']('etcd:server:version') -%}




runner-push-image:
  cmd.run:
    - name: docker push {{PRIDOMAIN}}/{{RUNNERIMG}}:{{ RUNNERVER }}

adapter-push-image:    
  cmd.run:
    - name: docker push {{PRIDOMAIN}}/{{ADAPTERIMG}}

pause-push-image:
  cmd.run:
    - name: docker push {{PRIDOMAIN}}/{{PAUSEIMG}}:{{ PAUSEVER }}

builder-push-image:    
  cmd.run:
    - name: docker push {{PRIDOMAIN}}/{{BUILDERIMG}}

push-plugin-tcm:
  cmd.run:
    - name: docker push {{PRIDOMAIN}}/{{TCMTAG}}

push-plugin-mesh:
  cmd.run:
    - name: docker push {{PRIDOMAIN}}/{{MESHTAG_META}}

push-calico:
  cmd.run:
    - name: docker push {{PRIDOMAIN}}/{{ CALICOIMG }}:{{ CALICOVER }}

push-etcd:
  cmd.run:
    - name: docker push {{PRIDOMAIN}}/{{ ETCDIMG }}:{{ ETCDVER }}

stop-lb:
  cmd.run:
    - name: docker stop rbd-lb

stop-hub:
  cmd.run:
    - name: docker stop rbd-hub
clear-stop:
    cmd.run:
        - name: cclear