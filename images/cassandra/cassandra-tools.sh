
source ./cassandra-cluster-env.sh

DEBUG=true

get_node_name()
{
	echo "cassandra-$1"
}

get_node_ip()
{
	echo "${IP_PREFIX}$((${IP_START} + $1))"
}

get_node_port_9042()
{
	if [ "x$1" != "x" ]; then 
		echo "$(($PORT_9042 + $1))" 
	fi
}

get_node_port_9160()
{
        if [ "x$1" != "x" ]; then
                echo "$(($PORT_9160 + $1))"
        fi
}

if [ "$1" = 'start' ]; then
    shift 1;
	while getopts v:n: opt
	do
		case $opt in
			n) node=$OPTARG
			;;
			v) version=$OPTARG
			;;
			\?) echo "Invalid option -$OPTARG"
			;;
		esac
	done
	
	if $DEBUG; then
		echo $(get_node_name $node)
		echo $(get_node_ip $node)
		echo $(get_node_port_9042 $node)
		echo $(get_node_port_9160 $node)
	fi


	if [[ -z "$version" ]]; then 
		echo "Missing version arg..."
		exit
	fi

    if [[ -z "$node" ]]; then
        echo "Missing node arg..."
		exit
    fi
 
    NODE_NAME=$(get_node_name $node) \
    NODE_VERSION=$version \
    NODE_IP=$(get_node_ip $node) \
    NODE_PORT_9042=$(get_node_port_9042 $node) \
    NODE_PORT_9160=$(get_node_port_9160 $node) \
    NODE_SEEDS=$CASSANDRA_SEEDS \
	docker-compose -f docker-compose-single.yaml up --no-recreate
fi


