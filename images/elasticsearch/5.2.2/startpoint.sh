#!/bin/bash
set -e

ELASTICSEARCH_CONFIG=$ELASTICSEARCH_HOME/config
ELASTICSEARCH_CONFIG_FILE=$ELASTICSEARCH_CONFIG/elasticsearch.yml
ELASTICSEARCH_BIN=$ELASTICSEARCH_HOME/bin
ELASTICSEARCH_DATA_DIR=/data/elasticsearch
ELASTICSEARCH_LOGS_DIR=/logs/elasticsearch

ELASTICSEARCH_HOST_IP=`hostname --ip-address | cut -f 1 -d ' '`

if [[ -z "$ELASTICSEARCH_HOST_IP" ]]; then
    export ELASTICSEARCH_HOST_IP=$ELASTICSEARCH_IP
fi

if [[ -z "$ELASTICSEARCH_CLUSTER_NAME" ]]; then
    export ELASTICSEARCH_CLUSTER_NAME="TestCluster"
fi

if [[ -z "$ELASTICSEARCH_NODE_NAME" ]]; then
    export ELASTICSEARCH_NODE_NAME=node-$ELASTICSEARCH_HOST_IP
fi

if [[ -z "$ELASTICSEARCH_PATH_DATA" ]]; then
    export ELASTICSEARCH_PATH_DATA=${ELASTICSEARCH_DATA_DIR}
fi

if [[ -z "$ELASTICSEARCH_PATH_LOGS" ]]; then
    export ELASTICSEARCH_PATH_LOGS=${ELASTICSEARCH_LOGS_DIR}
fi

if [[ -z "$ELASTICSEARCH_NETWORK_HOST" ]]; then
    export ELASTICSEARCH_NETWORK_HOST=${ELASTICSEARCH_HOST_IP}
fi

if [[ -z "$ELASTICSEARCH_HTTP_PORT" ]]; then
    export ELASTICSEARCH_HTTP_PORT=9200
fi

for VAR in `env`
do
  if [[ $VAR =~ ^ELASTICSEARCH_ && ! $VAR =~ ^ELASTICSEARCH_HOME && ! $VAR =~ ^ELASTICSEARCH_USER && ! $VAR =~ ^ELASTICSEARCH_HOST_IP &&  ! $VAR =~ ^ELASTICSEARCH_VERSION ]]; then
    elasticsearch_name=`echo "$VAR" | sed -r "s/ELASTICSEARCH_(.*)=.*/\1/g" | tr '[:upper:]' '[:lower:]' | tr _ .`
    env_var=`echo "$VAR" | sed -r "s/(.*)=.*/\1/g"`
    if egrep -q "(^|^#)?$elasticsearch_name:" $ELASTICSEARCH_CONFIG_FILE; then
        sed -r -i "s@(^|^#)?($elasticsearch_name):(.*)@\2: ${!env_var}@g" $ELASTICSEARCH_CONFIG_FILE #note that no config values may contain an '@' char
    else
        echo "$elasticsearch_name: ${!env_var}" >> $ELASTICSEARCH_CONFIG_FILE
    fi
  fi
done

if [ ! -d "$ELASTICSEARCH_PATH_DATA" ]; then
    mkdir -p $ELASTICSEARCH_PATH_DATA
fi

if [ ! -d "$ELASTICSEARCH_PATH_LOGS" ]; then
    mkdir -p $ELASTICSEARCH_PATH_LOGS
fi

chown elasticsearch:elasticsearch $ELASTICSEARCH_PATH_DATA
chown elasticsearch:elasticsearch $ELASTICSEARCH_PATH_LOGS

if [[ -n "$CUSTOM_INIT_SCRIPT" ]] ; then
  eval $CUSTOM_INIT_SCRIPT
fi

ELASTICSEARCH_PID=0

term_handler() {
  if [ $ELASTICSEARCH_PID -ne 0 ]; then
    kill -s TERM "$ELASTICSEARCH_PID"
    wait "$ELASTICSEARCH_PID"
  fi
  echo 'elasticsearch stopped.'
  exit
}

trap "term_handler" SIGHUP SIGINT SIGTERM
su elasticsearch -c "$ELASTICSEARCH_BIN/elasticsearch"
ELASTICSEARCH_PID=$!
wait "$ELASTICSEARCH_PID"
