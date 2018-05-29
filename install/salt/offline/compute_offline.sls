update_compute_hostname:
  cmd.run:
    - name: hostname {{ grains['id'] }}; echo "{{ grains['id'] }}" > /etc/hostname

sync_pkg:
  file.directory:
    - name: ~/rainbond-install/install
    - mkdirs: True

update_local_pkg_cache:
  cmd.run:
    - name: yum makecache fast

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
      - salt-minion
    - refresh: true
