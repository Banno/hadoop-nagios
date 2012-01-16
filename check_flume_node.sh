#!/bin/bash
set -x
is_running=0
flume_node_pid=0

if [ -f /var/run/flume/flume-*-node.pid ]; then
	flume_node_pid=`cat /var/run/flume/flume-*-node.pid`
else
	echo "Flume pid file not found!"
	exit 3
fi

if [ $flume_node_pid != 0 ]; then
	lines=`ps -p $flume_node_pid | wc -l`
else
	echo "Flume node not running!"
	exit 3
fi

if [ $lines -ge 2 ]; then 
	echo "Flume node is running!"
	exit 0
else 
	echo "Flume node is not running or pid file not found!"
	exit 3
fi

