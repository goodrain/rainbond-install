firewalld:
  service.dead:
    - name: firewalld
    - enable: False 

dnsmasq:
  service.dead:
    - name: dnsmasq
    - enable: False
  cmd.run:
    - name: killall -9  dnsmasq
    - onlyif: pgrep  dnsmasq

remove_pkgs:
  pkg.removed:
    - pkgs:
      - nscd
      - dnsmasq

NetworkManager:
  service.dead:
    - name: NetworkManager
    - enable: False
