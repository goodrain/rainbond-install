dps:
    cmd.run:
      - name: docker run --rm -v /var/run/docker.sock:/var/run/docker.sock rainbond/archiver gr-docker-utils
      - unless: which dps
    
dc-compose:
    cmd.run:
      - name: docker run --rm -v /var/run/docker.sock:/var/run/docker.sock rainbond/archiver gr-docker-compose
      - unless: which dc-compose
