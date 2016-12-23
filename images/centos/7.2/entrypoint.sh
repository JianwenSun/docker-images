#!/bin/bash

while [ $# -gt 0 ]; do
  	COMMAND=$1
  	case $COMMAND in
    	-daemon) DAEMON_MODE="true"
      		shift
      	;;
    	*)
      		break
		;;
  	esac
done

env >> /etc/environment
/usr/sbin/sshd

if [ $# -eq 0 ]; then
	/bin/bash
else
	# Launch mode
	if [ "x$DAEMON_MODE" = "xtrue" ]; then
    	nohup "$@" 2>/dev/null &
	else
    	exec "$@"
	fi
fi
