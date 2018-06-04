{% if grains['id'] == "manage01" %}
{% set PLUGINIMG = salt['pillar.get']('plugins:image') -%}
{% set TCMTAG = salt['pillar.get']('plugins:tcm:tag') -%}
{% set MESHTAG = salt['pillar.get']('plugins:mesh:tag') -%}
{% set PUBDOMAIN = salt['pillar.get']('public-image-domain') -%}
{% set PRIDOMAIN = salt['pillar.get']('private-image-domain') -%}

pull-plugin-tcm:
  cmd.run:
    - name: docker pull {{ PUBDOMAIN }}/{{PLUGINIMG}}:{{TCMTAG}}
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
    - name: docker pull {{PUBDOMAIN}}/{{PLUGINIMG}}:{{MESHTAG}}
    - unless: docker inspect {{PUBDOMAIN}}/{{PLUGINIMG}}:{{MESHTAG}}

retag-plugin-mesh:
  cmd.run:
    - name: docker tag {{PUBDOMAIN}}/{{PLUGINIMG}}:{{MESHTAG}} {{PRIDOMAIN}}/{{MESHTAG}}
    - unless: docker inspect {{PRIDOMAIN}}/{{MESHTAG}}
    - require:
        - cmd: pull-plugin-mesh

push-plugin-mesh:
  cmd.run:
    - name: docker push {{PRIDOMAIN}}/{{MESHTAG}}
    - require:
        - cmd: retag-plugin-mesh

{% set RUNNERIMG = salt['pillar.get']('proxy:runner:image') -%}
{% set RUNNERVER = salt['pillar.get']('proxy:runner:version') -%}
runner-pull-image:
  cmd.run:
    - name: docker pull {{PUBDOMAIN}}/{{ RUNNERIMG }}:{{ RUNNERVER }}
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

{% set ADAPTERIMG = salt['pillar.get']('proxy:adapter:image') -%}
{% set ADAPTERVER = salt['pillar.get']('proxy:adapter:version') -%}
adapter-pull-image:
  cmd.run:
    - name: docker pull {{PUBDOMAIN}}/{{ ADAPTERIMG }}:{{ ADAPTERVER }}
    - unless: docker inspect {{PUBDOMAIN}}/{{ ADAPTERIMG }}:{{ ADAPTERVER }}

adapter-tag:
  cmd.run:
    - name: docker tag {{PUBDOMAIN}}/{{ ADAPTERIMG }}:{{ ADAPTERVER }} {{PRIDOMAIN}}/{{ADAPTERIMG}}:{{ ADAPTERVER }}
    - unless: docker inspect {{PRIDOMAIN}}/{{ADAPTERIMG}}:{{ ADAPTERVER }}
    - require:
        - cmd: adapter-pull-image

adapter-push-image:    
  cmd.run:
    - name: docker push {{PRIDOMAIN}}/{{ADAPTERIMG}}:{{ ADAPTERVER }}
    - require:
        - cmd: adapter-tag

{% set PAUSEIMG = salt['pillar.get']('proxy:pause:image') -%}
{% set PAUSEVER = salt['pillar.get']('proxy:pause:version') -%}
pause-pull-image:
  cmd.run:
    - name: docker pull {{PUBDOMAIN}}/{{ PAUSEIMG }}:{{ PAUSEVER }}
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

{% set BUILDERIMG = salt['pillar.get']('proxy:builder:image') -%}
{% set BUILDERVER = salt['pillar.get']('proxy:builder:version') -%}
builder-pull-image:
  cmd.run:
    - name: docker pull {{PUBDOMAIN}}/{{ BUILDERIMG }}:{{ BUILDERVER }}
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

{% else %}
builder-mpull-image:    
  cmd.run:
    - name: docker pull {{PRIDOMAIN}}/{{BUILDERIMG}}

pause-mpull-image:
  cmd.run:
    - name: docker pull {{PRIDOMAIN}}/{{PAUSEIMG}}:{{PAUSEVER}}
{% endif %}
