#!/usr/bin/env bash

# Script to setup the ```INSPIRE``` databases The following arguments are supported (in this order!):
#  * PORT (dfeault: 5432)
#  * HOST (default: localhost)
#  * POSTGRES_USER (default: postgres)
# Examples:
#  * ./setupDBs.sh
#  * ./setupDBs.sh 5433
#  * ./setupDBs.sh 5433 123.4.567.89
#  * ./setupDBs.sh 5433 123.4.567.89 otheruser

##### CONSTANTS
PORT=${1:-5432}
HOST=${2:-localhost}
POSTGRES_USER=${3:-postgres}

##### FUNCTIONS

function info {
 echo "Setup database "
 echo "  PORT: ${PORT}"
 echo "  HOST: ${HOST}"
 echo "  POSTGRES_USER: ${POSTGRES_USER}"
}

function createUser {
  echo "01: create user"
  psql -q  -h $HOST -p $PORT -U $POSTGRES_USER -f ${BASH_SOURCE%/*}/../ddl/01_create_deegree_user.sql
}

function setupDBs {
  for DIR in ${BASH_SOURCE%/*}/../ddl/*; do
      if [[ -d $DIR ]]; then
        echo "Setup from directory '${DIR}'"
        CREATEFILE=$(find $DIR -iname '02_create*')
        DBNAME=$(sed -n -e 's/^\(.*\)\(CREATE DATABASE \)/\1/p' $CREATEFILE)
        setupDatabaseAndPostgis $CREATEFILE $DBNAME
        executeDatabaseSpecificScripts $DIR $DBNAME
      fi
  done
}

function setupDatabaseAndPostgis {
  echo "Setup database '${DBNAME}'"
  psql -q -h $HOST -p $PORT -U $POSTGRES_USER -f $CREATEFILE
  echo "Create extension POSTGIS '${DBNAME}'"
  psql -q  -h $HOST -p $PORT -U $POSTGRES_USER -d $DBNAME -f ${BASH_SOURCE%/*}/../ddl/03_create_extension_postgis.sql
}

function executeDatabaseSpecificScripts {
  for SQLFILE in $DIR/*; do
    FILENAME=$(basename $SQLFILE)
    if [[ $FILENAME != 00_* ]] && [[ $FILENAME != 02_* ]]; then
      echo "  Execute script '${FILENAME}'"
      psql -q  -h $HOST -p $PORT -U deegree -d $DBNAME -f $SQLFILE
    fi
  done
}

##### EXECUTIONS
info
createUser
setupDBs