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

{% if grains['id'] == "manage01" %}
pull-plugin-tcm:
  cmd.run:
  {% if pillar['install-type']!="offline" %}
    - name: docker pull {{ PUBDOMAIN }}/{{PLUGINIMG}}:{{TCMTAG}}
  {% else %}
    - name: docker load -i {{ pillar['install-script-path'] }}/install/imgs/{{ PUBDOMAIN }}_{{PLUGINIMG}}_{{TCMTAG}}.gz
  {% endif %}
    - unless: docker inspect {{ PUBDOMAIN }}/{{PLUGINIMG}}:{{TCMTAG}}

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
  {% if pillar['install-type']!="offline" %}
    - name: docker pull {{PUBDOMAIN}}/{{PLUGINIMG}}:{{MESHTAG}}
  {% else %}
    - name: docker load -i {{ pillar['install-script-path'] }}/install/imgs/{{PUBDOMAIN}}_{{PLUGINIMG}}_{{MESHTAG}}.gz
  {% endif %}
    - unless: docker inspect {{PUBDOMAIN}}/{{PLUGINIMG}}:{{MESHTAG}}

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

runner-pull-image:
  cmd.run:
  {% if pillar['install-type']!="offline" %}
    - name: docker pull {{PUBDOMAIN}}/{{ RUNNERIMG }}:{{ RUNNERVER }}
  {% else %}
    - name: docker load -i {{ pillar['install-script-path'] }}/install/imgs/{{PUBDOMAIN}}_{{ RUNNERIMG }}_{{ RUNNERVER }}.gz
  {% endif %}
    - unless: docker inspect {{PUBDOMAIN}}/{{ RUNNERIMG }}:{{ RUNNERVER }}

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
  {% if pillar['install-type']!="offline" %}
    - name: docker pull {{PUBDOMAIN}}/{{ PAUSEIMG }}:{{ PAUSEVER }}
  {% else %}
    - name : docker load -i {{ pillar['install-script-path'] }}/install/imgs/{{PUBDOMAIN}}_{{ PAUSEIMG }}_{{ PAUSEVER }}.gz
  {% endif %}
    - unless: docker inspect {{PUBDOMAIN}}/{{ PAUSEIMG }}:{{ PAUSEVER }}

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
  {% if pillar['install-type']!="offline" %}
    - name: docker pull {{PUBDOMAIN}}/{{ BUILDERIMG }}:{{ BUILDERVER }}
  {% else %}
    - name: docker load -i {{ pillar['install-script-path'] }}/install/imgs/{{PUBDOMAIN}}_{{ BUILDERIMG }}_{{ BUILDERVER }}.gz
  {% endif %}
    - unless: docker inspect {{PUBDOMAIN}}/{{ BUILDERIMG }}:{{ BUILDERVER }}

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
#push etcd & calico image to goodrain.me

push-etcd-image:
  cmd.run:
    - name: docker push {{PRIDOMAIN}}/{{ETCDIMG}}:{{ETCDVER}}

push-calico-image:
  cmd.run:
    - name: docker push {{PRIDOMAIN}}/{{CALICOIMG}}:{{ CALICOVER }}

builder-mpull-image:    
  cmd.run:
    - name: docker pull {{PRIDOMAIN}}/{{BUILDERIMG}}

pause-mpull-image:
  cmd.run:
    - name: docker pull {{PRIDOMAIN}}/{{PAUSEIMG}}:{{PAUSEVER}}
{% else %}
runner-pull-image:
  cmd.run:
    - name: docker pull {{PRIDOMAIN}}/{{RUNNERIMG}}:{{ RUNNERVER }}
{% endif %}


{% set CFSSLIMG = salt['pillar.get']('kubernetes:cfssl:image') -%}
{% set CFSSLVER = salt['pillar.get']('kubernetes:cfssl:version') -%}
{% set PUBDOMAIN = salt['pillar.get']('public-image-domain') -%}
{% set PRIDOMAIN = salt['pillar.get']('private-image-domain') -%}

pull_cfssl_image:
  cmd.run:
  {% if pillar['install-type']!="offline" %}
    - name: docker pull {{PUBDOMAIN}}/{{ CFSSLIMG }}:{{ CFSSLVER }}
  {% else %}
    - name: docker load -i {{ pillar['install-script-path'] }}/install/imgs/{{PUBDOMAIN}}_{{ CFSSLIMG }}_{{ CFSSLVER }}.gz
  {% endif %}
    - unless: docker inspect {{PUBDOMAIN}}/{{ CFSSLIMG }}:{{ CFSSLVER }}

check_or_create_certificates:
  cmd.run:
    - name: docker run --rm -v /srv/salt/kubernetes/server/install/ssl:/ssl -w /ssl {{PUBDOMAIN}}/{{ CFSSLIMG }}:{{ CFSSLVER }} kip {{ pillar['master-private-ip'] }}
    - unless:
      - ls /srv/salt/kubernetes/server/install/ssl/*.pem
      - ls /srv/salt/kubernetes/server/install/ssl/*.csr
    - require:
      - cmd: pull_cfssl_image

{% set KUBECFGIMG = salt['pillar.get']('kubernetes:kubecfg:image') -%}
{% set KUBECFGVER = salt['pillar.get']('kubernetes:kubecfg:version') -%}
pull_kubecfg_image:
  cmd.run:
  {% if pillar['install-type']!="offline" %}
    - name: docker pull {{PUBDOMAIN}}/{{ KUBECFGIMG }}:{{ KUBECFGVER }}
  {% else %}
    - name: docker load -i {{ pillar['install-script-path'] }}/install/imgs/{{PUBDOMAIN}}_{{ KUBECFGIMG }}_{{ KUBECFGVER }}.gz
  {% endif %}
    - unless: docker inspect {{PUBDOMAIN}}/{{ KUBECFGIMG }}:{{ KUBECFGVER }}

check_or_create_kubeconfig:
  cmd.run:
    - name: docker run --rm -v /srv/salt/kubernetes/server/install/ssl:/etc/goodrain/kubernetes/ssl -v /srv/salt/kubernetes/server/install/kubecfg:/k8s {{PUBDOMAIN}}/{{ KUBECFGIMG }}:{{ KUBECFGVER }}
    - unless: ls /srv/salt/kubernetes/server/install/kubecfg/*.kubeconfig
    - require:
      - cmd: pull_kubecfg_image

{% set K8SCNIIMG = salt['pillar.get']('kubernetes:cni:image') -%}
{% set K8SCNIVER = salt['pillar.get']('kubernetes:cni:version') -%}
pull_k8s_cni_image:
  cmd.run:
  {% if pillar['install-type']!="offline" %}
    - name: docker pull {{PUBDOMAIN}}/{{ K8SCNIIMG }}:{{ K8SCNIVER }}
  {% else %}
    - name: docker load -i {{ pillar['install-script-path'] }}/install/imgs/{{PUBDOMAIN}}_{{ K8SCNIIMG }}_{{ K8SCNIVER }}.gz
  {% endif %}
    - unless: docker inspect {{PUBDOMAIN}}/{{ K8SCNIIMG }}:{{ K8SCNIVER }}

prepare_k8s_cni_tools:
  cmd.run:
    - name: docker run --rm -v /srv/salt/misc/file:/sysdir {{PUBDOMAIN}}/{{ K8SCNIIMG }}:{{ K8SCNIVER }} tar zxf /pkg.tgz -C /sysdir
    - require:
      - cmd: pull_k8s_cni_image
    - unless:
      - test -f /srv/salt/misc/file/bin/calicoctl
      - test -f /srv/salt/misc/file/bin/docker-compose
      - test -f /srv/salt/misc/file/bin/etcdctl
      - test -f /srv/salt/misc/file/bin/kubectl
      - test -f /srv/salt/misc/file/bin/kubelet
      - test -f /srv/salt/misc/file/cni/bin/calico
      - test -f /srv/salt/misc/file/cni/bin/calico-ipam
      - test -f /srv/salt/misc/file/cni/bin/loopback

{% set RBDCNIIMG = salt['pillar.get']('rainbond-modules:rbd-cni:image') -%}
{% set RBDCNIVER = salt['pillar.get']('rainbond-modules:rbd-cni:version') -%}
pull_rbd_cni_image:
  cmd.run:
  {% if pillar['install-type']!="offline" %}
    - name: docker pull {{PUBDOMAIN}}/{{ RBDCNIIMG }}:{{ RBDCNIVER }}
  {% else %}
    - name: docker load -i {{ pillar['install-script-path'] }}/install/imgs/{{PUBDOMAIN}}_{{ RBDCNIIMG }}_{{ RBDCNIVER }}.gz
  {% endif %}
    - unless: docker inspect {{PUBDOMAIN}}/{{ RBDCNIIMG }}:{{ RBDCNIVER }}
prepare_rbd_cni_tools:
  cmd.run:
    - name: docker run --rm -v /srv/salt/misc/file:/sysdir {{PUBDOMAIN}}/{{ RBDCNIIMG }}:{{ RBDCNIVER }} tar zxf /pkg.tgz -C /sysdir
    - require: 
      - cmd: pull_rbd_cni_image

proxy_kubeconfig:
  file.managed:
     - source: salt://kubernetes/server/install/kubecfg/kube-proxy.kubeconfig
     - name: /grdata/kubernetes/kube-proxy.kubeconfig
     - unless: ls /grdata/kubernetes/kube-proxy.kubeconfig
     - makedirs: True

#==================== rbd-worker ====================
{% set PUBDOMAIN = salt['pillar.get']('public-image-domain') -%}
{% set PRIDOMAIN = salt['pillar.get']('private-image-domain') -%}
{% set WORKERIMG = salt['pillar.get']('rainbond-modules:rbd-worker:image') -%}
{% set WORKERVER = salt['pillar.get']('rainbond-modules:rbd-worker:version') -%}

docker-pull-worker-image:
  cmd.run:
  {% if pillar['install-type']!="offline" %}
    - name: docker pull {{PUBDOMAIN}}/{{ WORKERIMG }}:{{ WORKERVER }}
  {% else %}
    - name: docker load -i {{ pillar['install-script-path'] }}/install/imgs/{{PUBDOMAIN}}_{{ WORKERIMG }}_{{ WORKERVER }}.gz
  {% endif %}
    - unless: docker inspect {{PUBDOMAIN}}/{{ WORKERIMG }}:{{ WORKERVER }}

worker-upstart:
  cmd.run:
    - name: dc-compose up -d rbd-worker
    - unless: check_compose rbd-worker
    - require:
      - cmd: docker-pull-worker-image

#==================== rbd-eventlog ====================
{% set EVLOGIMG = salt['pillar.get']('rainbond-modules:rbd-eventlog:image') -%}
{% set EVLOGVER = salt['pillar.get']('rainbond-modules:rbd-eventlog:version') -%}
docker-pull-eventlog-image:
  cmd.run:
  {%if pillar['install-type']!="offline" %}
    - name: docker pull {{PUBDOMAIN}}/{{ EVLOGIMG }}:{{ EVLOGVER }}
  {% else %}
    - name: docker load -i {{ pillar['install-script-path'] }}/install/imgs/{{PUBDOMAIN}}_{{ EVLOGIMG }}_{{ EVLOGVER }}.gz
  {% endif %}
    - unless: docker inspect {{PUBDOMAIN}}/{{ EVLOGIMG }}:{{ EVLOGVER }}

eventlog-upstart:
  cmd.run:
    - name: dc-compose up -d rbd-eventlog
    - unless: check_compose rbd-eventlog
    - require:
      - cmd: docker-pull-eventlog-image

#==================== rbd-entrance ====================
{% set ENTRANCEIMG = salt['pillar.get']('rainbond-modules:rbd-entrance:image') -%}
{% set ENTRANCEVER = salt['pillar.get']('rainbond-modules:rbd-entrance:version') -%}
docker-pull-entrance-image:
  cmd.run:
  {% if pillar['install-type']!="offline" %}
    - name: docker pull {{PUBDOMAIN}}/{{ ENTRANCEIMG }}:{{ ENTRANCEVER }}
  {% else %}
    - name: docker load -i {{ pillar['install-script-path'] }}/install/imgs/{{PUBDOMAIN}}_{{ ENTRANCEIMG }}_{{ ENTRANCEVER }}.gz
  {% endif %}
    - unless: docker inspect {{PUBDOMAIN}}/{{ ENTRANCEIMG }}:{{ ENTRANCEVER }}

entrance-upstart:
  cmd.run:
    - name: dc-compose up -d rbd-entrance
    - unless: check_compose rbd-entrance
    - require:
      - cmd: docker-pull-entrance-image

#==================== rbd-api ====================
{% set APIIMG = salt['pillar.get']('rainbond-modules:rbd-api:image') -%}
{% set APIVER = salt['pillar.get']('rainbond-modules:rbd-api:version') -%}
docker-pull-api-image:
  cmd.run:
  {% if pillar['install-type']!="offline" %}
    - name: docker pull {{PUBDOMAIN}}/{{ APIIMG }}:{{ APIVER }}
  {% else %}
    - name: docker load -i {{ pillar['install-script-path'] }}/install/imgs/{{PUBDOMAIN}}_{{ APIIMG }}_{{ APIVER }}.gz
  {% endif %}
    - unless: docker inspect {{PUBDOMAIN}}/{{ APIIMG }}:{{ APIVER }}

api-upstart:
  cmd.run:
    - name: dc-compose up -d rbd-api
    - unless: check_compose rbd-api
    - require:
      - cmd: docker-pull-api-image

#==================== rbd-chaos ====================
{% set CHAOSIMG = salt['pillar.get']('rainbond-modules:rbd-chaos:image') -%}
{% set CHAOSVER = salt['pillar.get']('rainbond-modules:rbd-chaos:version') -%}
docker-pull-chaos-image:
  cmd.run:
  {% if pillar['install-type']!="offline" %}
    - name: docker pull {{PUBDOMAIN}}/{{ CHAOSIMG }}:{{ CHAOSVER }}
  {% else %}
    - name: docker load -i {{ pillar['install-script-path'] }}/install/imgs/{{PUBDOMAIN}}_{{ CHAOSIMG }}_{{ CHAOSVER }}.gz
  {% endif %}
    - unless: docker inspect {{PUBDOMAIN}}/{{ CHAOSIMG }}:{{ CHAOSVER }}

chaos-upstart:
  cmd.run:
    - name: dc-compose up -d rbd-chaos
    - unless: check_compose rbd-chaos
    - require:
      - cmd: docker-pull-chaos-image

#==================== rbd-lb ====================
{% set LBIMG = salt['pillar.get']('rainbond-modules:rbd-lb:image') -%}
{% set LBVER = salt['pillar.get']('rainbond-modules:rbd-lb:version') -%}
docker-pull-lb-image:
  cmd.run:
  {% if pillar['install-type']!="offline" %}
    - name: docker pull {{PUBDOMAIN}}/{{ LBIMG }}:{{ LBVER }}
  {% else %}
    - name: docker load -i {{ pillar['install-script-path'] }}/install/imgs/{{PUBDOMAIN}}_{{ LBIMG }}_{{ LBVER }}.gz
  {% endif %}
    - unless: docker inspect {{PUBDOMAIN}}/{{ LBIMG }}:{{ LBVER }}

default_http_conf:
  file.managed:
    - source: salt://plugins/data/proxy.conf
    - name: {{ pillar['rbd-path'] }}/etc/rbd-lb/dynamics/dynamic_servers/default.http.conf
    - template: jinja
    - makedirs: True

proxy_site_ssl:
  file.recurse:
    - source: salt://proxy/ssl/goodrain.me
    - name: {{ pillar['rbd-path'] }}/etc/rbd-lb/dynamics/dynamic_certs/goodrain.me
    - makedirs: True

lb-upstart:
  cmd.run:
    - name: dc-compose up -d rbd-lb
    - unless: check_compose rbd-lb
    - require:
      - cmd: docker-pull-lb-image
      - file: default_http_conf
      - file: proxy_site_ssl

lb-restart:
  cmd.run:
    - name: dc-compose restart rbd-lb
    - onchanges:
      - file: default_http_conf
      - file: proxy_site_ssl
    - require:
      - cmd: docker-pull-lb-image
      - file: default_http_conf
      - file: proxy_site_ssl
#==================== rbd-mq ======================
{% set MQIMG = salt['pillar.get']('rainbond-modules:rbd-mq:image') -%}
{% set MQVER = salt['pillar.get']('rainbond-modules:rbd-mq:version') -%}
docker-pull-mq-image:
  cmd.run:
  {% if pillar['install-type']!="offline" %}
    - name: docker pull {{PUBDOMAIN}}/{{ MQIMG }}:{{ MQVER }}
  {% else %}
    - name: docker load -i {{ pillar['install-script-path'] }}/install/imgs/{{PUBDOMAIN}}_{{ MQIMG }}_{{ MQVER }}.gz
  {% endif %}
    - unless: docker inspect {{PUBDOMAIN}}/{{ MQIMG }}:{{ MQVER }}

mq-upstart:
  cmd.run:
    - name: dc-compose up -d rbd-mq
    - unless: check_compose rbd-mq
    - require:
      - cmd: docker-pull-mq-image

#==================== rbd-webcli ====================
{% set WEBCLIIMG = salt['pillar.get']('rainbond-modules:rbd-webcli:image') -%}
{% set WEBCLIVER = salt['pillar.get']('rainbond-modules:rbd-webcli:version') -%}
docker-pull-webcli-image:
  cmd.run:
  {% if pillar['install-type']!="offline" %}
    - name: docker pull {{PUBDOMAIN}}/{{ WEBCLIIMG }}:{{ WEBCLIVER }}
  {% else %}
    - name: docker load -i {{ pillar['install-script-path'] }}/install/imgs/{{PUBDOMAIN}}_{{ WEBCLIIMG }}_{{ WEBCLIVER }}.gz
  {% endif %}
    - unless: docker inspect {{PUBDOMAIN}}/{{ WEBCLIIMG }}:{{ WEBCLIVER }}

webcli-upstart:
  cmd.run:
    - name: dc-compose up -d rbd-webcli
    - unless: check_compose rbd-webcli
    - require:
      - cmd: docker-pull-webcli-image

#==================== rbd-app-ui ====================
{% set APPUIIMG = salt['pillar.get']('rainbond-modules:rbd-app-ui:image') -%}
{% set APPUIVER = salt['pillar.get']('rainbond-modules:rbd-app-ui:version') -%}
docker-pull-app-ui-image:
  cmd.run:
  {% if pillar['install-type']!="offline" %}
    - name: docker pull {{PUBDOMAIN}}/{{ APPUIIMG }}:{{ APPUIVER }}
  {% else %}
    - name: docker load -i {{ pillar['install-script-path'] }}/install/imgs/{{PUBDOMAIN}}_{{ APPUIIMG }}_{{ APPUIVER }}.gz
  {% endif %}
    - unless: docker inspect {{PUBDOMAIN}}/{{ APPUIIMG }}:{{ APPUIVER }}

app-ui-logs:
  cmd.run:
    - name: touch {{ pillar['rbd-path'] }}/logs/rbd-app-ui/goodrain.log
    - unless: ls {{ pillar['rbd-path'] }}/logs/rbd-app-ui/goodrain.log
    - require:
      - cmd: docker-pull-app-ui-image

app-ui-upstart:
  cmd.run:
    - name: dc-compose up -d rbd-app-ui
    - unless: check_compose rbd-app-ui
    - require:
      - cmd: docker-pull-app-ui-image

#==================== init region db ====================
{% if grains['id'] == "manage01" %}
update-app-ui:
  cmd.run:
    - name: docker exec rbd-app-ui python /app/ui/manage.py migrate && docker exec rbd-db touch /data/.inited
    - unless: docker exec rbd-db ls /data/.inited

update_sql:
  file.managed:
    - source: salt://plugins/data/init.sql
    - name: /tmp/init.sql
    - template: jinja
  
update_sql_sh:
  file.managed:
    - source: salt://plugins/data/init.sh
    - name: /tmp/init.sh
    - template: jinja
  cmd.run:
    - name: bash /tmp/init.sh
{% endif %}

#==================== rbd-monitor ====================

{% if "manage" in grains['id'] %}
{% set P8SIMG = salt['pillar.get']('rainbond-modules:rbd-monitor:image') -%}
{% set P8SVER = salt['pillar.get']('rainbond-modules:rbd-monitor:version') -%}
{% set PUBDOMAIN = salt['pillar.get']('public-image-domain') -%}
{% set PRIDOMAIN = salt['pillar.get']('private-image-domain') -%}

docker-pull-prom-image:
  cmd.run:
  {% if pillar['install-type']!="offline" %}
    - name: docker pull {{PUBDOMAIN}}/{{ P8SIMG }}:{{ P8SVER }}
  {% else %}
    - name: docker load -i {{ pillar['install-script-path'] }}/install/imgs/{{PUBDOMAIN}}_{{ P8SIMG }}_{{ P8SVER }}.gz
  {% endif %}
    - unless: docker inspect {{PUBDOMAIN}}/{{ P8SIMG }}:{{ P8SVER }}

create-prom-data:
  file.directory:
   - name: {{ pillar['rbd-path'] }}/data/prom
   - makedirs: True
   - user: root
   - group: root
   - mode: 755

prom-upstart:
  cmd.run:
    - name: dc-compose up -d rbd-monitor
    - unless: check_compose rbd-monitor
    - require:
      - file: create-prom-data
{% endif %}

{% set REPOIMG = salt['pillar.get']('rainbond-modules:rbd-repo:image') -%}
{% set REPOVER = salt['pillar.get']('rainbond-modules:rbd-repo:version') -%}
{% set PUBDOMAIN = salt['pillar.get']('public-image-domain') -%}
{% set PRIDOMAIN = salt['pillar.get']('private-image-domain') -%}

docker-pull-repo-image:
  cmd.run:
{% if pillar['install-type']!="offline" %}
    - name: docker pull {{PUBDOMAIN}}/{{ REPOIMG }}:{{ REPOVER }}
{% else %}
    - name: docker load -i {{ pillar['install-script-path'] }}/install/imgs/{{PUBDOMAIN}}_{{ REPOIMG }}_{{ REPOVER }}.gz
{% endif %}
    - unless: docker inspect {{PUBDOMAIN}}/{{ REPOIMG }}:{{ REPOVER }}

repo-upstart:
  cmd.run:
    - name: dc-compose up -d rbd-repo
    - unless: check_compose rbd-repo
    - require:
      - cmd: docker-pull-repo-image

{% set REGISTRYIMG = salt['pillar.get']('rainbond-modules:rbd-registry:image') -%}
{% set REGISTRYVER = salt['pillar.get']('rainbond-modules:rbd-registry:version') -%}
{% set PUBDOMAIN = salt['pillar.get']('public-image-domain') -%}
{% set PRIDOMAIN = salt['pillar.get']('private-image-domain') -%}

docker-pull-hub-image:
  cmd.run:
{% if pillar['install-type']!="offline" %}
    - name: docker pull {{PUBDOMAIN}}/{{ REGISTRYIMG }}:{{ REGISTRYVER }}
{% else %}
    - name: docker load -i {{ pillar['install-script-path'] }}/install/imgs/{{PUBDOMAIN}}_{{ REGISTRYIMG }}_{{ REGISTRYVER }}.gz
{% endif %}
    - unless: docker inspect {{PUBDOMAIN}}/{{ REGISTRYIMG }}:{{ REGISTRYVER }}

hub-upstart:
  cmd.run:
    - name: dc-compose up -d rbd-hub
    - unless: check_compose rbd-hub
    - require:
      - cmd: docker-pull-hub-image

{% if "manage" in grains['id'] %}
{% set DNSIMG = salt['pillar.get']('rainbond-modules:rbd-dns:image') -%}
{% set DNSVER = salt['pillar.get']('rainbond-modules:rbd-dns:version') -%}
{% set PUBDOMAIN = salt['pillar.get']('public-image-domain') -%}
{% set PRIDOMAIN = salt['pillar.get']('private-image-domain') -%}

docker-pull-dns-image:
  cmd.run:
{% if pillar['install-type']!="offline" %}
    - name: docker pull {{PUBDOMAIN}}/{{ DNSIMG }}:{{ DNSVER }}
{% else %}
    - name: docker load -i {{ pillar['install-script-path'] }}/install/imgs/{{PUBDOMAIN}}_{{ DNSIMG }}_{{ DNSVER }}.gz
{% endif %}
    - unless: docker inspect {{PUBDOMAIN}}/{{ DNSIMG }}:{{ DNSVER }}

dns-upstart:
  cmd.run:
    - name: dc-compose up -d rbd-dns
    - unless: check_compose rbd-dns
    - require:
      - cmd: docker-pull-dns-image

{% endif %}