#!/bin/bash

PROXY_PATH={{ pillar['rbd-path'] }}/etc/rbd-lb/dynamics/dynamic_servers/default.http.conf

docker ps -a | grep rbd-lb >/dev/null 2>&1
if [ "$?" -ne 0 ];then
    docker rm -f rbd-lb
fi

if [ ! -f "$PROXY_PATH" ];then
    rm -rf "$PROXY_PATH"
    echo $HUB $REPO
    cat > $PROXY_PATH <<EOF
upstream lang {
    server 127.0.0.1:8081;
}

upstream maven {
    server 127.0.0.1:8081;
}

upstream registry {
    server 127.0.0.1:5000;
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
    index index.html index.htm;

    server_name repo.goodrain.me;

    location / {
        try_files $uri $uri/ =404;
    }

}
EOF
fi