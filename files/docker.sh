#!/usr/bin/env bash

set -e

# Added path to 'tcctl' in PATH variable
cd "$(dirname "$0")"/../../ || exit
PATH=$(pwd)/cli:$PATH

# Enable git hooks
cp docs/installation/git-hooks/pre-commit .git/hooks/pre-commit && chmod +x .git/hooks/pre-commit

# Prepare local nginx server
sh/install/prepare-nginx.sh

#get DOCKER_APP_NAME from .env
if [[ -n $(sed -n -e "s/^DOCKER_APP_NAME=//p" .env ) ]]; then
  DOCKER_APP_NAME=$(sed -n -e "s/^DOCKER_APP_NAME=//p" .env )
fi

#temporary fix for mysql
maxcounter=30
counter=1
while ! docker-compose exec mysql mysql -h127.0.0.1 \
  -uroot -proot -e "show databases;" > /dev/null 2>&1; do
  sleep 1
  counter=$(( "$counter" + 1 ))
  if [ $counter -gt $maxcounter ]; then
    >&2 echo "We have been waiting for MySQL too long already; failing."
    exit 1
  fi;
done

docker-compose exec mysql mysql -h127.0.0.1 -uroot -proot \
  -e "GRANT ALL PRIVILEGES ON *.* TO 'tenantcloud'@'%';" &&
docker-compose exec mysql mysql -h127.0.0.1 -uroot -proot \
  -e "FLUSH PRIVILEGES;" &&
docker-compose exec mysql mysql -h127.0.0.1 -uroot -proot \
  -e "CREATE USER 'read'@'%' IDENTIFIED BY 'read';"
docker-compose exec mysql mysql -h127.0.0.1 -uroot -proot \
  -e "GRANT SELECT, SHOW VIEW ON *.* TO 'read'@'%';"
docker-compose exec mysql mysql -h127.0.0.1 -uroot -proot \
  -e "FLUSH PRIVILEGES;"
sh/php/composer.sh install --no-interaction --prefer-dist --optimize-autoloader
docker run --rm -it --network="${DOCKER_APP_NAME:-tc-home}"-network --mount source="${DOCKER_APP_NAME:-tc-home}"-nfsmount,target=/app \
  -w /app --entrypoint "/app/sh/install/minio.sh"  minio/mc:latest
docker-compose exec app php artisan passport:keys
docker-compose exec app php artisan migrate
docker-compose exec app php artisan elastic:migrate
docker-compose exec app php artisan db:seed
docker-compose exec app php artisan tc:devops:passport_install --force
docker-compose exec app php artisan tc:stax:dev:enable_for_system_user
yarn ci
yarn production
docker-compose exec app ln -s /app/resources/web /app/public/web
