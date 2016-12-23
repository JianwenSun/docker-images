VERSIONS=("1.2.4" "1.2.9" "2.0.9" "2.1.13" "3.9")
VERSIONS_SSTABLE_FORMAT=("-ib-" "-ic-" "-jb-" "-ka-" "mc-")

DEFAULT_VERSION=${VERSIONS[0]}

IP_PREFIX='172.20.0.'
IP_START=100

NODE_COUNT=3

PORT_9042=49040
PORT_9160=49160

CASSANDRA_SEEDS=
for (( i = 1; i <= ($NODE_COUNT); i++ )); do
        if [ "$i" = "${NODE_COUNT}" ]; then
                CASSANDRA_SEEDS="$CASSANDRA_SEEDS${IP_PREFIX}$(($IP_START + $i))"
        else
                CASSANDRA_SEEDS="$CASSANDRA_SEEDS${IP_PREFIX}$(($IP_START + $i)),"
        fi
done


