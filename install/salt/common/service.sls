firewalld:
  service.dead:
    - name: firewalld
    - enable: False 

dnsmasq:
  service.dead:
    - name: dnsmasq
    - enable: False
  cmd.run:
    - name: killall -9 dnsmasq
    - onlyif: pgrep dnsmasq

#kill-dhclient:
#  cmd.run:
#    - name: pkill -9 dhclient
#    - onlyif: pgrep dhclient

remove_pkgs:
  pkg.removed:
    - pkgs:
      - nscd
      - dnsmasq
#      - dhclient
    - require:
      - service: dnsmasq
      - cmd: dnsmasq
#      - cmd: kill-dhclient

NetworkManager:
  service.dead:
    - name: NetworkManager
    - enable: False

iptables:
  cmd.run:
    - name: iptables -F;iptables -X;iptables -Z
    - unless: iptables -L -nv  | grep DOCKER
