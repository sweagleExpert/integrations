#!/bin/bash
set +u

echo "####     VALIDATE INPUTS PROVIDED"
if [[ -z $MONGO_DB ]]; then
  echo " No DB name provided, using default"
  export MONGO_DB="sweagle"
fi
if [[ -z $MONGO_DB_USER ]]; then
  echo " No DB user provided, using default"
  export MONGO_DB_USER="staticTreeUser"
fi
if [[ -z $MONGO_DB_PASSWORD ]]; then
  echo " No DB password provided, using default"
  export MONGO_DB_PASSWORD="staticTreePassword"
fi

mongo --eval "db.auth('$MONGO_INITDB_ROOT_USERNAME', '$MONGO_INITDB_ROOT_PASSWORD'); \
    db = db.getSiblingDB('$MONGO_DB'); \
    db.createUser({ \
      user: '$MONGO_DB_USER', \
      pwd: '$MONGO_DB_PASSWORD', \
      roles: [{ role: 'readWrite', db: '$MONGO_DB' }] \
    });"

# Go back to set -u behavior as used in other mongo scripts
set -u
