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

#=================================================================
{% set PUBDOMAIN = salt['pillar.get']('public-image-domain') -%}
{% set PRIDOMAIN = salt['pillar.get']('private-image-domain') -%}

#===================== k8s image =================================
{% set CFSSLIMG = salt['pillar.get']('kubernetes:cfssl:image') -%}
{% set CFSSLVER = salt['pillar.get']('kubernetes:cfssl:version') -%}
{% set APIIMG = salt['pillar.get']('kubernetes:api:image') -%}
{% set APIVER = salt['pillar.get']('kubernetes:api:version') -%}
{% set CTLMGEIMG = salt['pillar.get']('kubernetes:manager:image') -%}
{% set CTLMGEVER = salt['pillar.get']('kubernetes:manager:version') -%}
{% set SDLIMG = salt['pillar.get']('kubernetes:schedule:image') -%}
{% set SDLVER = salt['pillar.get']('kubernetes:schedule:version') -%}
pull_cfssl_image:
  cmd.run:
    - name: docker pull {{PUBDOMAIN}}/{{ CFSSLIMG }}:{{ CFSSLVER }}

{% set KUBECFGIMG = salt['pillar.get']('kubernetes:kubecfg:image') -%}
{% set KUBECFGVER = salt['pillar.get']('kubernetes:kubecfg:version') -%}
pull_kubecfg_image:
  cmd.run:
    - name: docker pull {{PUBDOMAIN}}/{{ KUBECFGIMG }}:{{ KUBECFGVER }}

pull_api_image:
  cmd.run:
    - name: docker pull {{PUBDOMAIN}}/{{ APIIMG }}:{{ APIVER }}
    - unless: docker inspect {{PUBDOMAIN}}/{{ APIIMG }}:{{ APIVER }}

pull_manager_image:
  cmd.run:
    - name: docker pull {{PUBDOMAIN}}/{{ CTLMGEIMG }}:{{ APIVER }}
    - unless: docker inspect {{PUBDOMAIN}}/{{ CTLMGEIMG }}:{{ APIVER }}

pull_schedule_image:
  cmd.run:
    - name: docker pull {{PUBDOMAIN}}/{{ SDLIMG }}:{{ SDLVER }}
    - unless: docker inspect {{PUBDOMAIN}}/{{ SDLIMG }}:{{ SDLVER }}

#===================== etcd image ================================
{% set ETCDIMG = salt['pillar.get']('etcd:server:image') -%}
{% set ETCDVER = salt['pillar.get']('etcd:server:version') -%}
docker-pull-etcd-image:
  cmd.run:
    - name: docker pull {{PUBDOMAIN}}/{{ ETCDIMG }}:{{ ETCDVER }}
#===================== network image =============================
{% set CALICOIMG = salt['pillar.get']('network:calico:image') -%}
{% set CALICOVER = salt['pillar.get']('network:calico:version') -%}
pull-calico-image:
  cmd.run:
    - name: docker pull {{PUBDOMAIN}}/{{ CALICOIMG }}:{{ CALICOVER }}

#===================== db image ==================================
{% set DBIMG = salt['pillar.get']('database:mysql:image') -%}
{% set DBVER = salt['pillar.get']('database:mysql:version') -%}
docker-pull-db-image:
  cmd.run:
    - name: docker pull {{PUBDOMAIN}}/{{ DBIMG }}:{{ DBVER }}

#===================== base image ================================

{% if "manage" in grains['id'] %}
{% set DNSIMG = salt['pillar.get']('rainbond-modules:rbd-dns:image') -%}
{% set DNSVER = salt['pillar.get']('rainbond-modules:rbd-dns:version') -%}
docker-pull-dns-image:
  cmd.run:
    - name: docker pull {{PUBDOMAIN}}/{{ DNSIMG }}:{{ DNSVER }}

{% set REGISTRYIMG = salt['pillar.get']('rainbond-modules:rbd-registry:image') -%}
{% set REGISTRYVER = salt['pillar.get']('rainbond-modules:rbd-registry:version') -%}
docker-pull-hub-image:
  cmd.run:
    - name: docker pull {{PUBDOMAIN}}/{{ REGISTRYIMG }}:{{ REGISTRYVER }}

{% set REPOIMG = salt['pillar.get']('rainbond-modules:rbd-repo:image') -%}
{% set REPOVER = salt['pillar.get']('rainbond-modules:rbd-repo:version') -%}
docker-pull-repo-image:
  cmd.run:
    - name: docker pull {{PUBDOMAIN}}/{{ REPOIMG }}:{{ REPOVER }}
{% endif %}

{% set RBDCNIIMG = salt['pillar.get']('rainbond-modules:rbd-cni:image') -%}
{% set RBDCNIVER = salt['pillar.get']('rainbond-modules:rbd-cni:version') -%}
pull_rbd_cni_image:
  cmd.run:
    - name: docker pull {{PUBDOMAIN}}/{{ RBDCNIIMG }}:{{ RBDCNIVER }}

{% set K8SCNIIMG = salt['pillar.get']('kubernetes:cni:image') -%}
{% set K8SCNIVER = salt['pillar.get']('kubernetes:cni:version') -%}
pull_k8s_cni_image:
  cmd.run:
    - name: docker pull {{PUBDOMAIN}}/{{ K8SCNIIMG }}:{{ K8SCNIVER }}

#===================== plugin image ==============================

{% set WORKERIMG = salt['pillar.get']('rainbond-modules:rbd-worker:image') -%}
{% set WORKERVER = salt['pillar.get']('rainbond-modules:rbd-worker:version') -%}

docker-pull-worker-image:
  cmd.run:
    - name: docker pull {{PUBDOMAIN}}/{{ WORKERIMG }}:{{ WORKERVER }}

{% set EVLOGIMG = salt['pillar.get']('rainbond-modules:rbd-eventlog:image') -%}
{% set EVLOGVER = salt['pillar.get']('rainbond-modules:rbd-eventlog:version') -%}
docker-pull-eventlog-image:
  cmd.run:
    - name: docker pull {{PUBDOMAIN}}/{{ EVLOGIMG }}:{{ EVLOGVER }}

{% set ENTRANCEIMG = salt['pillar.get']('rainbond-modules:rbd-entrance:image') -%}
{% set ENTRANCEVER = salt['pillar.get']('rainbond-modules:rbd-entrance:version') -%}
docker-pull-entrance-image:
  cmd.run:
    - name: docker pull {{PUBDOMAIN}}/{{ ENTRANCEIMG }}:{{ ENTRANCEVER }}

{% set LBIMG = salt['pillar.get']('rainbond-modules:rbd-lb:image') -%}
{% set LBVER = salt['pillar.get']('rainbond-modules:rbd-lb:version') -%}
docker-pull-lb-image:
  cmd.run:
    - name: docker pull {{PUBDOMAIN}}/{{ LBIMG }}:{{ LBVER }}

{% set CHAOSIMG = salt['pillar.get']('rainbond-modules:rbd-chaos:image') -%}
{% set CHAOSVER = salt['pillar.get']('rainbond-modules:rbd-chaos:version') -%}
docker-pull-chaos-image:
  cmd.run:
    - name: docker pull {{PUBDOMAIN}}/{{ CHAOSIMG }}:{{ CHAOSVER }}

{% set APIIMG = salt['pillar.get']('rainbond-modules:rbd-api:image') -%}
{% set APIVER = salt['pillar.get']('rainbond-modules:rbd-api:version') -%}
docker-pull-api-image:
  cmd.run:
    - name: docker pull {{PUBDOMAIN}}/{{ APIIMG }}:{{ APIVER }}

{% set APPUIIMG = salt['pillar.get']('rainbond-modules:rbd-app-ui:image') -%}
{% set APPUIVER = salt['pillar.get']('rainbond-modules:rbd-app-ui:version') -%}
docker-pull-app-ui-image:
  cmd.run:
    - name: docker pull {{PUBDOMAIN}}/{{ APPUIIMG }}:{{ APPUIVER }}

{% set MQIMG = salt['pillar.get']('rainbond-modules:rbd-mq:image') -%}
{% set MQVER = salt['pillar.get']('rainbond-modules:rbd-mq:version') -%}
docker-pull-mq-image:
  cmd.run:
    - name: docker pull {{PUBDOMAIN}}/{{ MQIMG }}:{{ MQVER }}

{% set WEBCLIIMG = salt['pillar.get']('rainbond-modules:rbd-webcli:image') -%}
{% set WEBCLIVER = salt['pillar.get']('rainbond-modules:rbd-webcli:version') -%}
docker-pull-webcli-image:
  cmd.run:
    - name: docker pull {{PUBDOMAIN}}/{{ WEBCLIIMG }}:{{ WEBCLIVER }}

{% if "manage" in grains['id'] %}
{% set P8SIMG = salt['pillar.get']('rainbond-modules:rbd-monitor:image') -%}
{% set P8SVER = salt['pillar.get']('rainbond-modules:rbd-monitor:version') -%}

docker-pull-prom-image:
  cmd.run:
    - name: docker pull {{PUBDOMAIN}}/{{ P8SIMG }}:{{ P8SVER }}
{% endif %}

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

runner-push-image:
  cmd.run:
    - name: docker push {{PRIDOMAIN}}/{{RUNNERIMG}}:{{ RUNNERVER }}
    - require:
        - cmd: runner-tag

adapter-pull-image:
  cmd.run:
  {% if pillar['install-type']!="offline" %}
    - name: docker pull {{PUBDOMAIN}}/{{ ADAPTERIMG }}:{{ ADAPTERVER }}
  {% else %}
    - name: docker load -i {{ pillar['install-script-path'] }}/install/imgs/{{PUBDOMAIN}}_{{ ADAPTERIMG }}_{{ ADAPTERVER }}.gz
  {% endif %}
    - unless: docker inspect {{PUBDOMAIN}}/{{ ADAPTERIMG }}:{{ ADAPTERVER }}

adapter-tag:
  cmd.run:
    - name: docker tag {{PUBDOMAIN}}/{{ ADAPTERIMG }}:{{ ADAPTERVER }} {{PRIDOMAIN}}/{{ADAPTERIMG}}
    - unless: docker inspect {{PRIDOMAIN}}/{{ADAPTERIMG}}
    - require:
        - cmd: adapter-pull-image

adapter-push-image:    
  cmd.run:
    - name: docker push {{PRIDOMAIN}}/{{ADAPTERIMG}}
    - require:
        - cmd: adapter-tag

pause-pull-image:
  cmd.run:
    - name: docker pull {{PUBDOMAIN}}/{{ PAUSEIMG }}:{{ PAUSEVER }}

pause-tag:
  cmd.run:
    - name: docker tag {{PUBDOMAIN}}/{{ PAUSEIMG }}:{{ PAUSEVER }} {{PRIDOMAIN}}/{{PAUSEIMG}}:{{ PAUSEVER }}
    - unless: docker inspect {{PRIDOMAIN}}/{{PAUSEIMG}}:{{ PAUSEVER }}
    - require:
        - cmd: pause-pull-image

pause-push-image:
  cmd.run:
    - name: docker push {{PRIDOMAIN}}/{{PAUSEIMG}}:{{ PAUSEVER }}
    - require:
        - cmd: pause-tag

builder-pull-image:
  cmd.run:
    - name: docker pull {{PUBDOMAIN}}/{{ BUILDERIMG }}:{{ BUILDERVER }}

builder-tag:  
  cmd.run:
    - name: docker tag {{PUBDOMAIN}}/{{ BUILDERIMG }}:{{ BUILDERVER }} {{PRIDOMAIN}}/{{BUILDERIMG}}:{{ BUILDERVER }}
    - unless: docker inspect {{PRIDOMAIN}}/{{BUILDERIMG}}:{{ BUILDERVER }}
    - require:
        - cmd: builder-pull-image

builder-push-image:    
  cmd.run:
    - name: docker push {{PRIDOMAIN}}/{{BUILDERIMG}}:{{ BUILDERVER }}
    - require:
        - cmd: builder-tag

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

push-plugin-tcm:
  cmd.run:
    - name: docker push {{PRIDOMAIN}}/{{TCMTAG}}
    - require:
        - cmd: retag-plugin-tcm

pull-plugin-mesh:
  cmd.run:
    - name: docker pull {{PUBDOMAIN}}/{{PLUGINIMG}}:{{MESHTAG}}

retag-plugin-mesh:
  cmd.run:
    - name: docker tag {{PUBDOMAIN}}/{{PLUGINIMG}}:{{MESHTAG}} {{PRIDOMAIN}}/{{MESHTAG_META}}
    - unless: docker inspect {{PRIDOMAIN}}/{{MESHTAG_META}}
    - require:
        - cmd: pull-plugin-mesh

push-plugin-mesh:
  cmd.run:
    - name: docker push {{PRIDOMAIN}}/{{MESHTAG_META}}
    - require:
        - cmd: retag-plugin-mesh

#===================== init rainbond ============================

#==================== init region db ====================
{% if grains['id'] == "manage01" %}
update-app-ui:
  cmd.run:
    - name: docker exec rbd-app-ui python /app/ui/manage.py migrate && docker exec rbd-db touch /data/.inited
    - unless: docker exec rbd-db ls /data/.inited

update_sql:
  file.managed:
    - source: salt://install/files/plugins/init.sql
    - name: /tmp/init.sql
    - template: jinja
  
update_sql_sh:
  file.managed:
    - source: salt://install/files/plugins/init.sh
    - name: /tmp/init.sh
    - template: jinja
  cmd.run:
    - name: bash /tmp/init.sh
{% endif %}

#==================== init lb ====================
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

proxy_kubeconfig:
  file.managed:
     - source: salt://kubernetes/kubecfg/kube-proxy.kubeconfig
     - name: /grdata/kubernetes/kube-proxy.kubeconfig
     - unless: ls /grdata/kubernetes/kube-proxy.kubeconfig
     - makedirs: True


prepare_rbd_cni_tools:
  cmd.run:
    - name: docker run --rm -v /srv/salt/misc/file:/sysdir {{PUBDOMAIN}}/{{ RBDCNIIMG }}:{{ RBDCNIVER }} tar zxf /pkg.tgz -C /sysdir

prepare_k8s_cni_tools:
  cmd.run:
    - name: docker run --rm -v /srv/salt/misc/file:/sysdir {{PUBDOMAIN}}/{{ K8SCNIIMG }}:{{ K8SCNIVER }} tar zxf /pkg.tgz -C /sysdir

check_or_create_kubeconfig:
  cmd.run:
    - name: docker run --rm -v /srv/salt/kubernetes/server/install/ssl:/etc/goodrain/kubernetes/ssl -v /srv/salt/kubernetes/server/install/kubecfg:/k8s {{PUBDOMAIN}}/{{ KUBECFGIMG }}:{{ KUBECFGVER }}
    - unless: ls /srv/salt/kubernetes/server/install/kubecfg/*.kubeconfig

check_or_create_certificates:
  cmd.run:
    - name: docker run --rm -v /srv/salt/kubernetes/server/install/ssl:/ssl -w /ssl {{PUBDOMAIN}}/{{ CFSSLIMG }}:{{ CFSSLVER }} kip {{ pillar['master-private-ip'] }}
    - unless:
      - ls /srv/salt/kubernetes/server/install/ssl/*.pem
      - ls /srv/salt/kubernetes/server/install/ssl/*.csr