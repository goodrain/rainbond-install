rbd-path: /opt/rainbond
inet-ip: 172.16.0.169
role: manage
dns: 8.8.8.8
host-uuid: xxxxxxx
rbd-version: 3.5
install-script-path: /root
rbd-tag: cloudbang
manage:
  - ip: 172.16.0.169
  - ip: 172.16.0.170
    

check_system:
  cmd.run:
    - name: /root/rainbond-install/scripts/check.sh
minion_install:
  cmd.run:
    - name: bash /root/rainbond-install/scripts/check.sh