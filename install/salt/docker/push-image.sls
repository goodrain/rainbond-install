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


upstart-lb:
    cmd.run:
        - name: dc-compose up -d rbd-lb

upstart-hub:
    cmd.run:
        - name: dc-compose up -d rbd-hub

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

stop-lb:
    cmd.run:
        - name: dc-compose stop rbd-lb

stop-hub:
    cmd.run:
        - name: dc-compose stop rbd-hub
clear-stop:
    cmd.run:
        - name: cclear