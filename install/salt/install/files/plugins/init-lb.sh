#!/bin/bash

PROXY_PATH={{ pillar['rbd-path'] }}/etc/rbd-lb/dynamics/dynamic_servers/default.http.conf

docker ps -a | grep rbd-lb >/dev/null 2>&1
if [ "$?" -eq 0 ];then
    docker rm -f rbd-lb
fi

HUB_CLUSTER=""
REPO_CLUSTER=""

for hub in $(echo $HUB | tr "," "\n" | sort -u)
do
	member="server $hub;"
	if [ -z $HUB_CLUSTER ];then
		HUB_CLUSTER=$member
	else
		HUB_CLUSTER="$HUB_CLUSTER $member"
	fi
done

for repo in $(echo $REPO | tr "," "\n" | sort -u)
do
	member="server $repo;"
	if [ -z $REPO_CLUSTER ];then
		REPO_CLUSTER=$member
	else
		REPO_CLUSTER="$REPO_CLUSTER $member"
	fi
done

if [ ! -z "$REPO_CLUSTER" -a ! -z "$HUB_CLUSTER" ];then
rm -rf "$PROXY_PATH"
echo $HUB $REPO
cat > $PROXY_PATH <<EOF
upstream lang {
    $REPO_CLUSTER
}

upstream maven {
    $REPO_CLUSTER
}

upstream registry {
    ip_hash;
    $HUB_CLUSTER
}

server {
    listen 80;
    server_name lang.goodrain.me;
    rewrite ^/(.*)$ /artifactory/pkg_lang/\$1 break;
    location / {
        proxy_pass http://lang;
        proxy_set_header Host \$host;
        proxy_redirect off;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_connect_timeout 60;
        proxy_read_timeout 600;
        proxy_send_timeout 600;
    }
}

server {
    listen 80;
    server_name maven.goodrain.me;
    location / {
        rewrite ^/(.*)$ /artifactory/libs-release/\$1 break;
        proxy_pass http://maven;
        proxy_set_header Host \$host;
        proxy_redirect off;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_connect_timeout 60;
        proxy_read_timeout 600;
        proxy_send_timeout 600;
    }

    location /monitor {
        return 204;
    }
}

server {
    listen 443;
    server_name goodrain.me;
    ssl on;
    ssl_certificate /usr/local/openresty/nginx/conf/dynamics/dynamic_certs/goodrain.me/server.crt;
    ssl_certificate_key /usr/local/openresty/nginx/conf/dynamics/dynamic_certs/goodrain.me/server.key;
    client_max_body_size 0;
    chunked_transfer_encoding on;
    location /v2/ {
        proxy_pass http://registry;
        proxy_set_header Host \$http_host; # required for docker client's sake
        proxy_set_header X-Real-IP \$remote_addr; # pass on real client's IP
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_read_timeout 900;
    }
}
# repo.goodrain.me
server {
    listen 80;
    root /opt/rainbond/install/install/pkgs/centos/;
    server_name repo.goodrain.me;

}
EOF

fi