#!/bin/bash

##########################################
###### INIT SWEAGLE REQUIRED DBs
###### Inspired from MySQL official docker-entrypoint.#!/bin/sh
###### https://github.com/docker-library/mysql/blob/master/5.7/docker-entrypoint.sh
##########################################

# Rewrite logging functions
mysql_log() {
	local type="$1"; shift
	printf '%s [%s] [SWEAGLE Init Script]: %s\n' "$(date --rfc-3339=seconds)" "$type" "$*"
}

# file_env function exists in entrypoint script
# second parameter is default value if none provided
file_env 'VAULT_DB' 'vault'
file_env 'VAULT_DB_USER' 'vault_user'
file_env 'VAULT_DB_PASSWORD' 'vault_password'

# We don't create the MDM db and user as they were already created by entrypoint script
# We create only VAULT db and user
mysql_note "Creating database ${VAULT_DB}"
docker_process_sql --database=mysql <<<"CREATE DATABASE IF NOT EXISTS \`$VAULT_DB\` ;"

mysql_note "Creating user ${VAULT_DB_USER}"
docker_process_sql --database=mysql <<<"CREATE USER IF NOT EXISTS '$VAULT_DB_USER'@'%' IDENTIFIED BY '$VAULT_DB_PASSWORD' ;"

mysql_note "Giving user ${VAULT_DB_USER} access to schema ${VAULT_DB}"
docker_process_sql --database=mysql <<<"GRANT ALL ON \`$VAULT_DB\`.* TO '$VAULT_DB_USER'@'%' ;"

docker_process_sql --database=mysql <<<"FLUSH PRIVILEGES ;"
