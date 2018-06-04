update_compute_hostname:
  cmd.run:
    - name: hostname {{ grains['id'] }}; echo "{{ grains['id'] }}" > /etc/hostname

dns-manage:
  cmd.run: 
    - name: echo 'nameserver {{ pillar['inet-ip'] }}' > /etc/resolv.conf

backup-repo-dir:
  file.directory:
    - name: /etc/yum.repos.d/backup
    - mkdir: True
    - unless: /etc/yum.repos.d/backup

backup-repo:
  cmd.run:
    - name: mv -f /etc/yum.repos.d/*.repo /etc/yum.repos.d/backup
    
local-repo:
  pkgrepo.managed:
    - humanname: local_repo
    - baseurl: http://repo.goodrain.me/
    - enabled: 1
    - gpgcheck: 0

update_local_pkg_cache:
  cmd.run:
    - name: yum makecache fast
    - require:
      - cmd: backup-repo
      - pkgrepo: local-repo

salt-minion-conf:
  file.managed:
    - name: /etc/salt/minion.d/minion.conf
    - source: salt://minions/install/conf/minion.conf
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - defaults:
    - minion_id: {{ grains['id'] }}

salt-minion-install:
  pkg.installed:
    - pkgs:
      - salt-minion
    - refresh: True
    - unless: rpm -qa | grep salt-minion
    - require: 
      - pkgrepo: local-repo

minion_service:
  service.running:
    - name: salt-minion
    - enable: True
    - require:
      - file: salt-minion-conf
      - pkg: salt-minion-install