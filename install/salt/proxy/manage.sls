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
    - require:
        - cmd: runner-pull-image

runner-push-image:
  cmd.run:
    - name: docker push goodrain.me/runner
    - require:
        - cmd: runner-tag

adapter-pull-image:
  cmd.run:
    - name: docker pull rainbond/adapter

adapter-tag:
  cmd.run:
    - name: docker tag rainbond/adapter goodrain.me/adapter
    - require:
        - cmd: adapter-pull-image

adapter-push-image:    
  cmd.run:
    - name: docker push goodrain.me/adapter
    - require:
        - cmd: adapter-tag

pause-pull-image:
  cmd.run:
    - name: docker pull rainbond/pause-amd64:3.0

pause-tag:
  cmd.run:
    - name: docker tag rainbond/pause-amd64:3.0 goodrain.me/pause-amd64:3.0
    - require:
        - cmd: pause-pull-image

pause-push-image:
  cmd.run:
    - name: docker push goodrain.me/pause-amd64:3.0
    - require:
        - cmd: pause-tag

builder-pull-image:
  cmd.run:
    - name: docker pull rainbond/builder

builder-tag:  
  cmd.run:
    - name: docker tag rainbond/builder goodrain.me/builder
    - require:
        - cmd: builder-pull-image

builder-push-image:    
  cmd.run:
    - name: docker push goodrain.me/builder
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
  


