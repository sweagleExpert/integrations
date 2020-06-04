#!/bin/bash
echo "###############################################################"
echo "### BEGIN VAULT START SCRIPT V3"
echo "###############################################################"

##########################################################
#                    MAIN
##########################################################
echo "#####     VALIDATE INPUTS PROVIDED"
CONFIG_FILE=$1

if [[ -z ${VAULT_DB} ]]; then
  echo " No DB provided, using default"
  export VAULT_DB="vault"
fi

if [[ -z ${VAULT_DB_USER} ]]; then
  echo " No db user provided, using default"
  export VAULT_DB_USER="vault_user"
fi

if [[ -z ${VAULT_DB_PASSWORD} ]]; then
  echo " No db password provided, using default"
  export VAULT_DB_PASSWORD="vault_password"
fi

# replace vault config file values by environment settings
eval "echo \"$(cat /opt/vault/templates/${CONFIG_FILE})\"" > "/opt/vault/${CONFIG_FILE}"

# start unseal in background.
# As it sleeps for few seconds, it will allow vault to start before init or unseal
unseal.sh &

vault server -config="/opt/vault/${CONFIG_FILE}"
