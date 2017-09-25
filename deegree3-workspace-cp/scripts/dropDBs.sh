#!/usr/bin/env bash

#Script to drop the ```INSPIRE``` databases. The following arguments are supported (in this order!):
#  * PORT (dfeault: 5432)
#  * HOST (default: localhost)
#  * POSTGRES_USER (default: postgres)
# Examples:
#  * ./dropDBs.sh
#  * ./dropDBs.sh 5433
#  * ./dropDBs.sh 5433 123.4.567.89
#  * ./dropDBs.sh 5433 123.4.567.89 otheruser


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

function dropDBs {
  for DIR in ${BASH_SOURCE%/*}/../ddl/*; do
      if [[ -d $DIR ]]; then
        dropDB $DIR
      fi
  done
}

function dropDB {
  echo "Drop from directory '${DIR}'"
  DROPFILE=$(find $DIR -iname '00_drop*')
  echo "  Execute script '$(basename $DROPFILE)'"
  psql -q -h $HOST -p $PORT -U $POSTGRES_USER -f $DROPFILE

}

##### EXECUTIONS
info
dropDBs