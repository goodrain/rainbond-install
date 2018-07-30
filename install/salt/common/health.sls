health-check-rsync:
  file.recurse:
    - source: salt://install/files/health
    - name: {{ pillar['rbd-path'] }}/health/
    - file_mode: 777

