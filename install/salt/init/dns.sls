# add records to /etc/hosts file

# get master(manage01) ip address
{% set hostip = pillar['master-ip'] %}

rbd-repo-domain:
  host.present:
    - ip: {{ hostip }}
    - names:
      - lang.goodrain.me
      - maven.goodrain.me

kube-apiserver-domain:
  host.present:
    - ip: {{ hostip }}
    - names:
      - kubeapi.goodrain.me

rbd-api-domain:
  host.present:
    - ip: {{ hostip }}
    - names:
      - region.goodrain.me

rbd-registry-domain:
  host.present:
    - ip: {{ hostip }}
    - names:
      - goodrain.me

rbd-app-ui-domain:
  host.present:
    - ip: {{ hostip }}
    - names:
      - console.goodrain.me

# Modify /etc/resolv.conf
/etc/resolv.conf:
  file.append:
    - text:
      - "nameserver {{ pillar['dns'] }}"