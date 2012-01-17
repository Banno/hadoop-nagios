#!/bin/bash

if [ "$1" == "" ]; then
	echo "Hostname undefined"
	echo "Usage: $0 host.name.here"
	exit 3
fi

flume_status=`echo "getnodestatus" | flume shell -c $1 2>&1 | tail -n 2  |sed 's/\t//g' | awk '{print $3}' | sed 's/\n//g' | head -n 1`


echo "Flume Status: $flume_status"
if [ "$flume_status" == "ERROR" ]; then
	exit 2
elif [ "$flume_status" == "ACTIVE" ]; then
	exit 0
else 
	exit 3
fi
