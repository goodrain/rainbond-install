<<<<<<< HEAD
{% if grains['id'] == "manage01" %}
pull-plugin-tcm:
  cmd.run:
    - name: docker pull rainbond/plugins:tcm

retag-plugin-tcm:
  cmd.run:
    - name: docker tag rainbond/plugins:tcm goodrain.me/tcm
    - require:
        - cmd: pull-plugin-tcm


push-plugin-tcm:
  cmd.run:
    - name: docker push goodrain.me/tcm
    - require:
        - cmd: retag-plugin-tcm

pull-plugin-mesh:
  cmd.run:
    - name: docker pull rainbond/plugins:mesh_plugin

retag-plugin-mesh:
  cmd.run:
    - name: docker tag rainbond/plugins:mesh_plugin goodrain.me/mesh_plugin
    - require:
        - cmd: pull-plugin-mesh

push-plugin-mesh:
  cmd.run:
    - name: docker push goodrain.me/mesh_plugin
    - require:
        - cmd: retag-plugin-mesh

runner-pull-image:
  cmd.run:
    - name: docker pull rainbond/runner

runner-tag:
  cmd.run:
    - name: docker tag rainbond/runner goodrain.me/runner
=======
{% set RUNNERIMG = salt['pillar.get']('proxy:runner:image') -%}
{% set RUNNERVER = salt['pillar.get']('proxy:runner:version') -%}
runner-pull-image:
  cmd.run:
    - name: docker pull {{ RUNNERIMG }}:{{ RUNNERVER }}
    - unless: docker inspect {{ RUNNERIMG }}:{{ RUNNERVER }}

runner-tag:
  cmd.run:
    - name: docker tag {{ RUNNERIMG }}:{{ RUNNERVER }} goodrain.me/runner:{{ RUNNERVER }}
    - unless: docker inspect goodrain.me/runner:{{ RUNNERVER }}
>>>>>>> reconsitution
    - require:
        - cmd: runner-pull-image

runner-push-image:
  cmd.run:
    - name: docker push goodrain.me/runner:{{ RUNNERVER }}
    - require:
        - cmd: runner-tag

{% set ADAPTERIMG = salt['pillar.get']('proxy:adapter:image') -%}
{% set ADAPTERVER = salt['pillar.get']('proxy:adapter:version') -%}
adapter-pull-image:
  cmd.run:
<<<<<<< HEAD
    - name: docker pull rainbond/adapter

adapter-tag:
  cmd.run:
    - name: docker tag rainbond/adapter goodrain.me/adapter
=======
    - name: docker pull {{ ADAPTERIMG }}:{{ ADAPTERVER }}
    - unless: docker inspect {{ ADAPTERIMG }}:{{ ADAPTERVER }}

adapter-tag:
  cmd.run:
    - name: docker tag {{ ADAPTERIMG }}:{{ ADAPTERVER }} goodrain.me/adapter:{{ ADAPTERVER }}
    - unless: docker inspect goodrain.me/adapter:{{ ADAPTERVER }}
>>>>>>> reconsitution
    - require:
        - cmd: adapter-pull-image

adapter-push-image:    
  cmd.run:
    - name: docker push goodrain.me/adapter:{{ ADAPTERVER }}
    - require:
        - cmd: adapter-tag

{% set PAUSEIMG = salt['pillar.get']('proxy:pause:image') -%}
{% set PAUSEVER = salt['pillar.get']('proxy:pause:version') -%}
pause-pull-image:
  cmd.run:
<<<<<<< HEAD
    - name: docker pull rainbond/pause-amd64:3.0

pause-tag:
  cmd.run:
    - name: docker tag rainbond/pause-amd64:3.0 goodrain.me/pause-amd64:3.0
=======
    - name: docker pull {{ PAUSEIMG }}:{{ PAUSEVER }}
    - unless: docker inspect {{ PAUSEIMG }}:{{ PAUSEVER }}

pause-tag:
  cmd.run:
    - name: docker tag {{ PAUSEIMG }}:{{ PAUSEVER }} goodrain.me/pause-amd64:{{ PAUSEVER }}
    - unless: docker inspect goodrain.me/pause-amd64:{{ PAUSEVER }}
>>>>>>> reconsitution
    - require:
        - cmd: pause-pull-image

pause-push-image:
  cmd.run:
    - name: docker push goodrain.me/pause-amd64:{{ PAUSEVER }}
    - require:
        - cmd: pause-tag

{% set BUILDERIMG = salt['pillar.get']('proxy:builder:image') -%}
{% set BUILDERVER = salt['pillar.get']('proxy:builder:version') -%}
builder-pull-image:
  cmd.run:
<<<<<<< HEAD
    - name: docker pull rainbond/builder

builder-tag:  
  cmd.run:
    - name: docker tag rainbond/builder goodrain.me/builder
=======
    - name: docker pull {{ BUILDERIMG }}:{{ BUILDERVER }}
    - unless: docker inspect {{ BUILDERIMG }}:{{ BUILDERVER }}

builder-tag:  
  cmd.run:
    - name: docker tag {{ BUILDERIMG }}:{{ BUILDERVER }} goodrain.me/builder:{{ BUILDERVER }}
    - unless: docker inspect goodrain.me/builder:{{ BUILDERVER }}
>>>>>>> reconsitution
    - require:
        - cmd: builder-pull-image

builder-push-image:    
  cmd.run:
    - name: docker push goodrain.me/builder:{{ BUILDERVER }}
    - require:
        - cmd: builder-tag

{% else %}
builder-mpull-image:    
  cmd.run:
    - name: docker pull goodrain.me/builder

pause-mpull-image:
  cmd.run:
    - name: docker pull goodrain.me/pause-amd64:3.0

pause-mpull-image:
  cmd.run:
    - name: docker pull rainbond/pause-amd64:3.0
{% endif %}
  


