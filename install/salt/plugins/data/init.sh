#!/bin/bash

docker cp /tmp/init.sql rbd-db:/root
docker exec rbd-db mysql -e "use console;source /root/init.sql;"

