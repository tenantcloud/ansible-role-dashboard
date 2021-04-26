#!/usr/bin/env bash

echo "We will be using local nginx as a proxy to make HTTPS requests"
echo "Set Nginx worker_processes to auto"

gsed -i "s/^worker_processes  1;/worker_processes  auto;/g" /usr/local/etc/nginx/nginx.conf

echo "Set nginx worker_rlimit_nofile to 20000"

if ! grep -q "worker_rlimit_nofile    20000;" /usr/local/etc/nginx/nginx.conf; then
  gsed -i '/worker_processes  auto;/a worker_rlimit_nofile    20000;' /usr/local/etc/nginx/nginx.conf
fi

echo "Set client_max_body_size to 512M"

if ! grep -q "client_max_body_size 512M;" /usr/local/etc/nginx/nginx.conf; then
  gsed -i '/http {/a\    client_max_body_size 512M;' /usr/local/etc/nginx/nginx.conf
fi

echo "Create nginx ssl directory if doesn't exist"

mkdir -p /usr/local/etc/nginx/ssl

echo "Copy ssl certificates for tc.loc domain"

cp -r docs/installation/ssl/tc.loc.* /usr/local/etc/nginx/ssl

echo "Copy nginx virtual host config file"

cp -r docker/proxy/conf.d/*.conf /usr/local/etc/nginx/servers

echo "Add *.tc.loc domains in /etc/hosts"

if ! grep -q "127.0.0.1 home.tc.loc" /etc/hosts; then
  echo "127.0.0.1 *.tc.loc home.tc.loc socket.tc.loc minio.tc.loc mail.tc.loc \
supervisor.tc.loc elasticsearch.tc.loc social.localhost.tenants.cloud selenoid.tc.loc" \
  | sudo tee -a /etc/hosts
fi

echo "Restart local nginx server"

sudo brew services restart nginx

echo "That's all!"
echo "Have a nice day!"
