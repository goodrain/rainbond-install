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
<<<<<<< HEAD
    - enable: False

iptables:
  cmd.run:
    - name: iptables -F;iptables -X;iptables -Z
=======
    - enable: False
>>>>>>> a0e5b0ca4965023e91c128b03e5f57c5eb8c5063
