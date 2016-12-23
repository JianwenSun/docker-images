#!/bin/bash

set -e

CASSANDRA_CONFIG=$CASSANDRA_HOME/conf
CASSANDRA_CONFIG_FILE=$CASSANDRA_CONFIG/cassandra.yaml
CASSANDRA_BIN=$CASSANDRA_HOME/bin
CASSANDRA_ENV_FILE=$CASSANDRA_CONFIG/cassandra-env.sh
CASSANDRA_DATA_DIR="/cassandra/data/$HOSTNAME"

CASSANDRA_IP=`hostname --ip-address | cut -f 1 -d ' '`

# Disable virtual nodes
# sed -i -e "s/num_tokens/\#num_tokens/" $CASSANDRA_CONFIG/cassandra.yaml

if [[ -z "$CASSANDRA_CLUSTER_NAME" ]]; then
    export CASSANDRA_CLUSTER_NAME="TestCluster"
fi

if [[ -z "$CASSANDRA_NUM_TOKENS" ]]; then
    export CASSANDRA_NUM_TOKENS=1
fi

if [[ -z "$CASSANDRA_PARTITIONER" ]]; then
    export CASSANDRA_PARTITIONER="org.apache.cassandra.dht.RandomPartitioner"
fi

if [[ -z "$CASSANDRA_COMMITLOG_DIRECTORY" ]]; then
    export CASSANDRA_COMMITLOG_DIRECTORY="${CASSANDRA_DATA_DIR}/commitlog"
fi

if [[ -z "$CASSANDRA_SAVED_CACHES_DIRECTORY" ]]; then
    export CASSANDRA_SAVED_CACHES_DIRECTORY="${CASSANDRA_DATA_DIR}/saved_caches"
fi

if [[ -z "$CASSANDRA_HINTS_DIRECTORY" ]]; then
    export CASSANDRA_HINTS_DIRECTORY="${CASSANDRA_DATA_DIR}/hints"
fi

if [[ -z "$CASSANDRA_CDC_RAW_DIRECTORY" ]]; then
    export CASSANDRA_CDC_RAW_DIRECTORY="${CASSANDRA_DATA_DIR}/cdc_raw"
fi

if [[ -z "$CASSANDRA_START_RPC" ]]; then
    export CASSANDRA_START_RPC="true"
fi

if [[ -z "$CASSANDRA_RPC_ADDRESS" ]]; then
    export CASSANDRA_RPC_ADDRESS=$CASSANDRA_IP
fi

if [[ -z "$CASSANDRA_LISTEN_ADDRESS" ]]; then
    export CASSANDRA_LISTEN_ADDRESS=$CASSANDRA_IP
fi

# cassandra seed_provider
if [[ -z "$CASSANDRA_SEEDS" ]]; then
    sed -i -e "s/- seeds: \"127.0.0.1\"/- seeds: \"$CASSANDRA_IP\"/" $CASSANDRA_CONFIG_FILE
else
    sed -i -e "s/- seeds: \"127.0.0.1\"/- seeds: \"$CASSANDRA_SEEDS\"/" $CASSANDRA_CONFIG_FILE
fi

if [[ "x$CASSANDRA_DATA_DIR" != "x" ]]; then
    sed -i '/.*data_file_directories:/{n;d}' $CASSANDRA_CONFIG_FILE
    sed -i '/.*data_file_directories:/a\    - '$CASSANDRA_DATA_DIR'' $CASSANDRA_CONFIG_FILE
fi

for VAR in `env`
do
  if [[ $VAR =~ ^CASSANDRA_ && ! $VAR =~ ^CASSANDRA_HOME && ! $VAR =~ ^CASSANDRA_USER && ! $VAR =~ ^CASSANDRA_VERSION && ! $VAR =~ ^CASSANDRA_SEEDS ]]; then
    cassandra_name=`echo "$VAR" | sed -r "s/CASSANDRA_(.*)=.*/\1/g" | tr '[:upper:]' '[:lower:]'`
    env_var=`echo "$VAR" | sed -r "s/(.*)=.*/\1/g"`
    if egrep -q "(^|^#)?$cassandra_name:" $CASSANDRA_CONFIG_FILE; then
        sed -r -i "s@(^|^#)?($cassandra_name):(.*)@\2: ${!env_var}@g" $CASSANDRA_CONFIG_FILE #note that no config values may contain an '@' char
    else
        echo "$cassandra_name: ${!env_var}" >> $CASSANDRA_CONFIG_FILE
    fi
  fi
done

# The stack size specified is too small, Specify at least 228k
sed -ri 's/('"-Xss180k"')/'"-Xss1m"'/' "$CASSANDRA_ENV_FILE"

sed -i '/x$LOCAL_JMX/i\LOCAL_JMX=no\n' "$CASSANDRA_ENV_FILE"
sed -ri 's/(Dcom.sun.management.jmxremote.authenticate=true)/\Dcom.sun.management.jmxremote.authenticate=false/' "$CASSANDRA_ENV_FILE"
sed -ri 's/(#JVM_OPTS='"$JVM_OPTS -Dcom.sun.management.jmxremote.ssl=true"')/JVM_OPTS='"$JVM_OPTS -Dcom.sun.management.jmxremote.ssl=false"'/' "$CASSANDRA_ENV_FILE"

if [[ -n "$CUSTOM_INIT_SCRIPT" ]] ; then
  eval $CUSTOM_INIT_SCRIPT
fi

CASSANDRA_PID=0

term_handler() {
  if [ $CASSANDRA_PID -ne 0 ]; then
    kill -s TERM "$CASSANDRA_PID"
    wait "$CASSANDRA_PID"
  fi
  echo 'cassandra stopped.'
  exit
}

trap "term_handler" SIGHUP SIGINT SIGTERM
$CASSANDRA_BIN/cassandra -f -R
CASSANDRA_PID=$!
wait "$CASSANDRA_PID"

