firewalld:
  service.dead:
    - name: firewalld
    - enable: False 

dnsmasq:
  service.dead:
    - name: dnsmasq
    - enable: False 

nscd:
  pkg.removed:
    - pkgs:
      - nscd

NetworkManager:
  service.dead:
    - name: NetworkManager
    - enable: False
