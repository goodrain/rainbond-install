#====================== type ========================================
{% set PUBDOMAIN = salt['pillar.get']('public-image-domain') -%}
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

docker-pull-lb-image:
  cmd.run:
    - name: docker pull {{PUBDOMAIN}}/{{ LBIMG }}:{{ LBVER }}

rename-pull-lb-image:
  cmd.run:
    - name: docker tag {{PUBDOMAIN}}/{{ LBIMG }}:{{ LBVER }} {{PRIDOMAIN}}/{{ LBIMG }}:{{ LBVER }}

docker-pull-hub-image:
  cmd.run:
    - name: docker pull {{PUBDOMAIN}}/{{ REGISTRYIMG }}:{{ REGISTRYVER }}

rename-pull-hub-image:
  cmd.run:
    - name: docker tag {{PUBDOMAIN}}/{{ REGISTRYIMG }}:{{ REGISTRYVER }} {{PRIDOMAIN}}/{{ REGISTRYIMG }}:{{ REGISTRYVER }}

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
{% set K8SCNIIMG = salt['pillar.get']('kubernetes:cni:image') -%}
{% set K8SCNIVER = salt['pillar.get']('kubernetes:cni:version') -%}
{% set RBDCNIIMG = salt['pillar.get']('rainbond-modules:rbd-cni:image') -%}
{% set RBDCNIVER = salt['pillar.get']('rainbond-modules:rbd-cni:version') -%}

pull_api_image:
  cmd.run:
    - name: docker pull {{PUBDOMAIN}}/{{ APIIMG }}:{{ APIVER }}
    - unless: docker inspect {{PUBDOMAIN}}/{{ APIIMG }}:{{ APIVER }}

rename_api_image:
  cmd.run:
    - name: docker tag {{PUBDOMAIN}}/{{ APIIMG }}:{{ APIVER }} {{PRIDOMAIN}}/{{ APIIMG }}:{{ APIVER }}

push_api_image:
  cmd.run:
    - name: docker push {{PRIDOMAIN}}/{{ APIIMG }}:{{ APIVER }}

pull_manager_image:
  cmd.run:
    - name: docker pull {{PUBDOMAIN}}/{{ CTLMGEIMG }}:{{ APIVER }}

rename_manager_image:
  cmd.run:
    - name: docker tag {{PUBDOMAIN}}/{{ CTLMGEIMG }}:{{ APIVER }} {{PRIDOMAIN}}/{{ CTLMGEIMG }}:{{ APIVER }}

push_manager_image:
  cmd.run:
    - name: docker push {{PRIDOMAIN}}/{{ CTLMGEIMG }}:{{ APIVER }}

pull_schedule_image:
  cmd.run:
    - name: docker pull {{PUBDOMAIN}}/{{ SDLIMG }}:{{ SDLVER }}
    - unless: docker inspect {{PUBDOMAIN}}/{{ SDLIMG }}:{{ SDLVER }}

rename_schedule_image:
  cmd.run:
    - name: docker tag {{PUBDOMAIN}}/{{ SDLIMG }}:{{ SDLVER }} {{PRIDOMAIN}}/{{ SDLIMG }}:{{ SDLVER }}

push_schedule_image:
  cmd.run:
    - name: docker push {{PRIDOMAIN}}/{{ SDLIMG }}:{{ SDLVER }}

#===================== etcd image ================================
{% set ETCDIMG = salt['pillar.get']('etcd:server:image') -%}
{% set ETCDVER = salt['pillar.get']('etcd:server:version') -%}
pull_etcd_image:
  cmd.run:
    - name: docker pull {{PUBDOMAIN}}/{{ ETCDIMG }}:{{ ETCDVER }}

rename_etcd_image:
  cmd.run:
    - name: docker tag {{PUBDOMAIN}}/{{ ETCDIMG }}:{{ ETCDVER }} {{PRIDOMAIN}}/{{ ETCDIMG }}:{{ ETCDVER }}

push_etcd_image:
  cmd.run:
    - name: docker push {{PRIDOMAIN}}/{{ ETCDIMG }}:{{ ETCDVER }}

#===================== network image =============================
{% set CALICOIMG = salt['pillar.get']('network:calico:image') -%}
{% set CALICOVER = salt['pillar.get']('network:calico:version') -%}
pull-calico-image:
  cmd.run:
    - name: docker pull {{PUBDOMAIN}}/{{ CALICOIMG }}:{{ CALICOVER }}

rename-calico-image:
  cmd.run:
    - name: docker tag {{PUBDOMAIN}}/{{ CALICOIMG }}:{{ CALICOVER }} {{PRIDOMAIN}}/{{ CALICOIMG }}:{{ CALICOVER }}

push-calico-image:
  cmd.run:
    - name: docker push {{PRIDOMAIN}}/{{ CALICOIMG }}:{{ CALICOVER }}

#===================== db image ==================================
{% set DBIMG = salt['pillar.get']('database:mysql:image') -%}
{% set DBVER = salt['pillar.get']('database:mysql:version') -%}
docker-pull-db-image:
  cmd.run:
    - name: docker pull {{PUBDOMAIN}}/{{ DBIMG }}:{{ DBVER }}

rename-db-image:
  cmd.run:
    - name: docker tag {{PUBDOMAIN}}/{{ DBIMG }}:{{ DBVER }}  {{PRIDOMAIN}}/{{ DBIMG }}:{{ DBVER }}

push-db-image:
  cmd.run:
    - name: docker push {{PRIDOMAIN}}/{{ DBIMG }}:{{ DBVER }}
#===================== base image ================================


{% set DNSIMG = salt['pillar.get']('rainbond-modules:rbd-dns:image') -%}
{% set DNSVER = salt['pillar.get']('rainbond-modules:rbd-dns:version') -%}
docker-pull-dns-image:
  cmd.run:
    - name: docker pull {{PUBDOMAIN}}/{{ DNSIMG }}:{{ DNSVER }}

rename-pull-dns-image:
  cmd.run:
    - name: docker tag {{PUBDOMAIN}}/{{ DNSIMG }}:{{ DNSVER }} {{PRIDOMAIN}}/{{ DNSIMG }}:{{ DNSVER }}

push-dns-image:
  cmd.run:
    - name: docker push {{PRIDOMAIN}}/{{ DNSIMG }}:{{ DNSVER }}

{% set REPOIMG = salt['pillar.get']('rainbond-modules:rbd-repo:image') -%}
{% set REPOVER = salt['pillar.get']('rainbond-modules:rbd-repo:version') -%}
docker-pull-repo-image:
  cmd.run:
    - name: docker pull {{PUBDOMAIN}}/{{ REPOIMG }}:{{ REPOVER }}

rename-pull-repo-image:
  cmd.run:
    - name: docker tag {{PUBDOMAIN}}/{{ REPOIMG }}:{{ REPOVER }} {{PRIDOMAIN}}/{{ REPOIMG }}:{{ REPOVER }}

push-repo-image:
  cmd.run:
    - name: docker push {{PRIDOMAIN}}/{{ REPOIMG }}:{{ REPOVER }}

#===================== plugin image ==============================

{% set WORKERIMG = salt['pillar.get']('rainbond-modules:rbd-worker:image') -%}
{% set WORKERVER = salt['pillar.get']('rainbond-modules:rbd-worker:version') -%}

docker-pull-worker-image:
  cmd.run:
    - name: docker pull {{PUBDOMAIN}}/{{ WORKERIMG }}:{{ WORKERVER }}

rename-pull-worker-image:
  cmd.run:
    - name: docker tag {{PUBDOMAIN}}/{{ WORKERIMG }}:{{ WORKERVER }} {{PRIDOMAIN}}/{{ WORKERIMG }}:{{ WORKERVER }}

push-worker-image:
  cmd.run:
    - name: docker push {{PRIDOMAIN}}/{{ WORKERIMG }}:{{ WORKERVER }}

{% set EVLOGIMG = salt['pillar.get']('rainbond-modules:rbd-eventlog:image') -%}
{% set EVLOGVER = salt['pillar.get']('rainbond-modules:rbd-eventlog:version') -%}
docker-pull-eventlog-image:
  cmd.run:
    - name: docker pull {{PUBDOMAIN}}/{{ EVLOGIMG }}:{{ EVLOGVER }}

rename-pull-eventlog-image:
  cmd.run:
    - name: docker tag {{PUBDOMAIN}}/{{ EVLOGIMG }}:{{ EVLOGVER }} {{PRIDOMAIN}}/{{ EVLOGIMG }}:{{ EVLOGVER }}

push-eventlog-image:
  cmd.run:
    - name: docker push {{PRIDOMAIN}}/{{ EVLOGIMG }}:{{ EVLOGVER }}

{% set ENTRANCEIMG = salt['pillar.get']('rainbond-modules:rbd-entrance:image') -%}
{% set ENTRANCEVER = salt['pillar.get']('rainbond-modules:rbd-entrance:version') -%}
docker-pull-entrance-image:
  cmd.run:
    - name: docker pull {{PUBDOMAIN}}/{{ ENTRANCEIMG }}:{{ ENTRANCEVER }}

rename-pull-entrance-image:
  cmd.run:
    - name: docker tag {{PUBDOMAIN}}/{{ ENTRANCEIMG }}:{{ ENTRANCEVER }} {{PRIDOMAIN}}/{{ ENTRANCEIMG }}:{{ ENTRANCEVER }}

push-entrance-image:
  cmd.run:
    - name: docker push {{PRIDOMAIN}}/{{ ENTRANCEIMG }}:{{ ENTRANCEVER }}

{% set CHAOSIMG = salt['pillar.get']('rainbond-modules:rbd-chaos:image') -%}
{% set CHAOSVER = salt['pillar.get']('rainbond-modules:rbd-chaos:version') -%}
docker-pull-chaos-image:
  cmd.run:
    - name: docker pull {{PUBDOMAIN}}/{{ CHAOSIMG }}:{{ CHAOSVER }}

rename-pull-chaos-image:
  cmd.run:
    - name: docker tag {{PUBDOMAIN}}/{{ CHAOSIMG }}:{{ CHAOSVER }} {{PRIDOMAIN}}/{{ CHAOSIMG }}:{{ CHAOSVER }}

push-chaos-image:
  cmd.run:
    - name: docker push {{PRIDOMAIN}}/{{ CHAOSIMG }}:{{ CHAOSVER }}


{% set APIIMG = salt['pillar.get']('rainbond-modules:rbd-api:image') -%}
{% set APIVER = salt['pillar.get']('rainbond-modules:rbd-api:version') -%}
docker-pull-api-image:
  cmd.run:
    - name: docker pull {{PUBDOMAIN}}/{{ APIIMG }}:{{ APIVER }}

rename-pull-api-image:
  cmd.run:
    - name: docker tag {{PUBDOMAIN}}/{{ APIIMG }}:{{ APIVER }} {{PRIDOMAIN}}/{{ APIIMG }}:{{ APIVER }}

push-api-image:
  cmd.run:
    - name: docker push {{PRIDOMAIN}}/{{ APIIMG }}:{{ APIVER }}

{% set APPUIIMG = salt['pillar.get']('rainbond-modules:rbd-app-ui:image') -%}
{% set APPUIVER = salt['pillar.get']('rainbond-modules:rbd-app-ui:version') -%}
docker-pull-app-ui-image:
  cmd.run:
    - name: docker pull {{PUBDOMAIN}}/{{ APPUIIMG }}:{{ APPUIVER }}

rename-pull-app-ui-image:
  cmd.run:
    - name: docker tag {{PUBDOMAIN}}/{{ APPUIIMG }}:{{ APPUIVER }} {{PRIDOMAIN}}/{{ APPUIIMG }}:{{ APPUIVER }}

push-app-ui-image:
  cmd.run:
    - name: docker push {{PRIDOMAIN}}/{{ APPUIIMG }}:{{ APPUIVER }}

{% set MQIMG = salt['pillar.get']('rainbond-modules:rbd-mq:image') -%}
{% set MQVER = salt['pillar.get']('rainbond-modules:rbd-mq:version') -%}
docker-pull-mq-image:
  cmd.run:
    - name: docker pull {{PUBDOMAIN}}/{{ MQIMG }}:{{ MQVER }}

rename-pull-mq-image:
  cmd.run:
    - name: docker tag {{PUBDOMAIN}}/{{ MQIMG }}:{{ MQVER }} {{PRIDOMAIN}}/{{ MQIMG }}:{{ MQVER }}

push-mq-image:
  cmd.run:
    - name: docker push {{PRIDOMAIN}}/{{ MQIMG }}:{{ MQVER }}


{% set WEBCLIIMG = salt['pillar.get']('rainbond-modules:rbd-webcli:image') -%}
{% set WEBCLIVER = salt['pillar.get']('rainbond-modules:rbd-webcli:version') -%}
docker-pull-webcli-image:
  cmd.run:
    - name: docker pull {{PUBDOMAIN}}/{{ WEBCLIIMG }}:{{ WEBCLIVER }}

rename-pull-webcli-image:
  cmd.run:
    - name: docker tag {{PUBDOMAIN}}/{{ WEBCLIIMG }}:{{ WEBCLIVER }} {{PRIDOMAIN}}/{{ WEBCLIIMG }}:{{ WEBCLIVER }}

push-webcli-image:
  cmd.run:
    - name: docker push {{PRIDOMAIN}}/{{ WEBCLIIMG }}:{{ WEBCLIVER }}


{% set P8SIMG = salt['pillar.get']('rainbond-modules:rbd-monitor:image') -%}
{% set P8SVER = salt['pillar.get']('rainbond-modules:rbd-monitor:version') -%}

docker-pull-prom-image:
  cmd.run:
    - name: docker pull {{PUBDOMAIN}}/{{ P8SIMG }}:{{ P8SVER }}

rename-pull-prom-image:
  cmd.run:
    - name: docker tag {{PUBDOMAIN}}/{{ P8SIMG }}:{{ P8SVER }} {{PRIDOMAIN}}/{{ P8SIMG }}:{{ P8SVER }}

push-prom-image:
  cmd.run:
    - name: docker push {{PRIDOMAIN}}/{{ P8SIMG }}:{{ P8SVER }}


#===================== builder/runner image ===========================

runner-pull-image:
  cmd.run:
    - name: docker pull {{PUBDOMAIN}}/{{ RUNNERIMG }}:{{ RUNNERVER }}

runner-tag:
  cmd.run:
    - name: docker tag {{PUBDOMAIN}}/{{ RUNNERIMG }}:{{ RUNNERVER }} {{PRIDOMAIN}}/{{RUNNERIMG}}:{{ RUNNERVER }}
    - unless: docker inspect {{PRIDOMAIN}}/{{RUNNERIMG}}:{{ RUNNERVER }}
    - require:
        - cmd: runner-pull-image


adapter-pull-image:
  cmd.run:
    - name: docker pull {{PUBDOMAIN}}/{{ ADAPTERIMG }}:{{ ADAPTERVER }}
    - unless: docker inspect {{PUBDOMAIN}}/{{ ADAPTERIMG }}:{{ ADAPTERVER }}

adapter-tag:
  cmd.run:
    - name: docker tag {{PUBDOMAIN}}/{{ ADAPTERIMG }}:{{ ADAPTERVER }} {{PRIDOMAIN}}/{{ADAPTERIMG}}
    - unless: docker inspect {{PRIDOMAIN}}/{{ADAPTERIMG}}
    - require:
        - cmd: adapter-pull-image

pause-pull-image:
  cmd.run:
    - name: docker pull {{PUBDOMAIN}}/{{ PAUSEIMG }}:{{ PAUSEVER }}

pause-tag:
  cmd.run:
    - name: docker tag {{PUBDOMAIN}}/{{ PAUSEIMG }}:{{ PAUSEVER }} {{PRIDOMAIN}}/{{PAUSEIMG}}:{{ PAUSEVER }}
    - unless: docker inspect {{PRIDOMAIN}}/{{PAUSEIMG}}:{{ PAUSEVER }}
    - require:
        - cmd: pause-pull-image

builder-pull-image:
  cmd.run:
    - name: docker pull {{PUBDOMAIN}}/{{ BUILDERIMG }}:{{ BUILDERVER }}

builder-tag:  
  cmd.run:
    - name: docker tag {{PUBDOMAIN}}/{{ BUILDERIMG }}:{{ BUILDERVER }} {{PRIDOMAIN}}/{{BUILDERIMG}}:{{ BUILDERVER }}
    - unless: docker inspect {{PRIDOMAIN}}/{{BUILDERIMG}}:{{ BUILDERVER }}
    - require:
        - cmd: builder-pull-image



#===================== addons image ==============================
pull-plugin-tcm:
  cmd.run:
    - name: docker pull {{ PUBDOMAIN }}/{{PLUGINIMG}}:{{TCMTAG}}

retag-plugin-tcm:
  cmd.run:
    - name: docker tag {{ PUBDOMAIN }}/{{PLUGINIMG}}:{{TCMTAG}} {{ PRIDOMAIN }}/{{TCMTAG}}
    - unless: docker inspect {{ PRIDOMAIN }}/{{TCMTAG}}
    - require:
        - cmd: pull-plugin-tcm

pull-plugin-mesh:
  cmd.run:
    - name: docker pull {{PUBDOMAIN}}/{{PLUGINIMG}}:{{MESHTAG}}

retag-plugin-mesh:
  cmd.run:
    - name: docker tag {{PUBDOMAIN}}/{{PLUGINIMG}}:{{MESHTAG}} {{PRIDOMAIN}}/{{MESHTAG_META}}
    - unless: docker inspect {{PRIDOMAIN}}/{{MESHTAG_META}}
    - require:
        - cmd: pull-plugin-mesh

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
    - name: docker push {{PRIDOMAIN}}/{{BUILDERIMG}}:{{ BUILDERVER }}

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