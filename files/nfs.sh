#!/usr/bin/env bash

# TODO: Add check nfs.sh run previously

OS=$(uname -s)

if [[ $OS != "Darwin" ]]; then
  echo "This script is OSX-only. Please do not run it on any other Unix."
  exit 1
fi

if [[ $EUID -eq 0 ]]; then
  echo "This script must NOT be run with sudo/root. Please re-run without sudo." 1>&2
  exit 1
fi

_shell_name=${0##*/}

if [[ $_shell_name == "bash" ]]; then
  echo "COMPOSE_DOCKER_CLI_BUILD=true" >> ~/.bashrc
elif [[ $_shell_name == "zsh" ]]; then
  echo "COMPOSE_DOCKER_CLI_BUILD=true" >> ~/.zshrc
fi

if ! docker ps > /dev/null 2>&1 ; then
  echo "== Waiting for docker to start..."
fi

open -a Docker

while ! docker ps > /dev/null 2>&1 ; do sleep 2; done

echo "== Stopping running docker containers..."
docker-compose down > /dev/null 2>&1
docker volume prune -f > /dev/null

osascript -e 'quit app "Docker"'

echo "== Resetting folder permissions..."
U=$(id -u)
G=$(id -g)
sudo chown -R "$U":"$G" .

echo "== Setting up nfs..."
LINE="/System/Volumes/Data/Users -alldirs -mapall=$U:$G localhost"
FILE=/etc/exports
sudo cp /dev/null $FILE
grep -qF -- "$LINE" "$FILE" || sudo echo "$LINE" | sudo tee -a $FILE > /dev/null

LINE="nfs.server.mount.require_resv_port = 0"
FILE=/etc/nfs.conf
grep -qF -- "$LINE" "$FILE" || sudo echo "$LINE" | sudo tee -a $FILE > /dev/null

echo "== Restarting nfsd..."
sudo nfsd restart

echo "== Restarting docker..."
open -a Docker

while ! docker ps > /dev/null 2>&1 ; do sleep 2; done

echo "Unlock keychain"
security unlock-keychain -p "qwerty123"
docker login registry.tenants.co

echo ""
echo "SUCCESS! Now go run your containers"
