#!/usr/bin/env bash

# shellcheck disable=SC1090

# Added path to 'tcctl' in PATH variable
cd "$(dirname "$0")"/../../ || exit
PATH=$(pwd)/cli:$PATH

#get DOCKER_APP_NAME from .env
if [[ -n $(sed -n -e "s/^DOCKER_APP_NAME=//p" .env ) ]]; then
  DOCKER_APP_NAME=$(sed -n -e "s/^DOCKER_APP_NAME=//p" .env )
fi

sleep 30

docker-compose exec -T mysql mysql -h127.0.0.1 -uroot -proot \
  -e "GRANT ALL PRIVILEGES ON *.* TO 'tenantcloud'@'%';" &&
docker-compose exec -T mysql mysql -h127.0.0.1 -uroot -proot \
  -e "FLUSH PRIVILEGES;" &&
docker-compose exec -T mysql mysql -h127.0.0.1 -uroot -proot \
  -e "CREATE USER 'read'@'%' IDENTIFIED BY 'read';"
docker-compose exec -T mysql mysql -h127.0.0.1 -uroot -proot \
  -e "GRANT SELECT, SHOW VIEW ON *.* TO 'read'@'%';"
docker-compose exec -T mysql mysql -h127.0.0.1 -uroot -proot \
  -e "FLUSH PRIVILEGES;"
docker-compose exec -T home composer install --no-interaction --prefer-dist --optimize-autoloader
docker run --rm -i --network=tc-"${DOCKER_APP_NAME:-home}"-network --mount source=tc-"${DOCKER_APP_NAME:-home}"-nfsmount,target=/app \
  -w /app --entrypoint "/app/sh/install/minio.sh"  minio/mc:latest
docker-compose exec -T home php artisan passport:keys
docker-compose exec -T home php artisan migrate
docker-compose exec -T home php artisan db:seed
docker-compose exec -T home php artisan tc:devops:passport_install --force
$(command -v yarn) ci
$(command -v yarn) release
docker-compose exec -T home ln -s /app/resources/web /app/public/web
