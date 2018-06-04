install_req_pkgs:
  pkg.installed:
    - pkgs:
      - nfs-utils
      - ntpdate
      - lsof
      - htop 
      - nload 
      - rsync 
      - net-tools
    - refresh: true
