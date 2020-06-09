#!/usr/bin/env bash

VAULT_CONFIG_FILE=~/.vault-configuration
VAULT_KEY_FILE=/etc/vault/init.file

function message() {
    echo "================================================================================"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] on $(hostname)"
    echo "--------------------------------------------------------------------------------"
    echo "$1"
    echo "--------------------------------------------------------------------------------"
}

function messageError() {
    exitCodeNumber=$?
    echo "================================================================================"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] on $(hostname)"
    echo "--------------------------------------------------------------------------------";
    echo "Exit code $exitCodeNumber"
    echo "$1"
    echo "--------------------------------------------------------------------------------";
    exit 1
}

function get_env_value() {
    if [[ -f "$2" ]]; then
        VARIABLE=$1
        FILENAME=$2
        echo $(sed -n -e "s/^\s*$VARIABLE\s*=//p" $FILENAME)
    fi
}

function vault_put() {
  source $VAULT_CONFIG_FILE
  vault_get_token
  VAULT_SECRETS=$1
  ENV_FILE=$2
  MSG="Put to vault"
  vault kv put $VAULT_SECRETS $(egrep -v '^#' $ENV_FILE | xargs) \
    && message "Success. $MSG" \
    || messageError "Error. $MSG"
}

function vault_get() {
  source $VAULT_CONFIG_FILE
  vault_get_token
  VAULT_SECRETS=$1
  ENV_FILE=$2
  MSG="Get from vault"
  vault kv get $VAULT_SECRETS | sed 's/\ \{1,\}/=/g' | sed 1,11d > /tmp/.env.vault
  vault_diff .env \
    && message "Success. $MSG" \
    || messageError "Error. $MSG"
}

function vault_config() {
  VAULT_ADDR=$1
  VAULT_NAME=$2
  VAULT_PASSWORD=$3
  MSG="Add vault_env to profile"
  echo 'export VAULT_ADDR='$VAULT_ADDR > $VAULT_CONFIG_FILE
  echo 'export VAULT_NAME='$VAULT_NAME >> $VAULT_CONFIG_FILE
  echo 'export VAULT_PASSWORD='$VAULT_PASSWORD >> $VAULT_CONFIG_FILE
  source $VAULT_CONFIG_FILE \
    && message "Success. $MSG" \
    || messageError "Error. $MSG"
}

function vault_get_token()  {
  source $VAULT_CONFIG_FILE
  MSG="Get token from vault server"
  VAULT_TOKEN=$(vault login -method=userpass username=${VAULT_NAME} password=${VAULT_PASSWORD} \
                | sed 1,6d | tr -s ' ' | cut -f 2 -d ' ' | sed -n 1p) \
    && message "Success. $MSG" \
    || messageError "Error. $MSG"
}

function vault_diff() {
  MSG="Сomparison completed"
  ENV_FILE=$1
  DIFF=$(diff -y --suppress-common-lines /tmp/.env.vault $ENV_FILE | column -t)
  echo "$DIFF"
}

function vault_check_path() {
  source $VAULT_CONFIG_FILE
  vault_get_token
  MSG="Get path from vault server"
  VAULT_SECRETS=$1
  VAULT_PATH=$(vault kv get $VAULT_SECRETS | sed 1,8d | head -1)
  echo $VAULT_PATH \
    && message "Success. $MSG" \
    || messageError "Error. $MSG"
}
