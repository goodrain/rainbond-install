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


#push etcd & calico image to goodrain.me

push-etcd-image:
  cmd.run:
    - name: docker push {{PRIDOMAIN}}/{{ETCDIMG}}:{{ETCDVER}}

push-calico-image:
  cmd.run:
    - name: docker push {{PRIDOMAIN}}/{{CALICOIMG}}:{{ CALICOVER }}

{% endif %}

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
