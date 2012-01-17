#!/bin/bash

flume_status=`echo "getnodestatus" | flume shell -c apps.banno.com 2>&1 | tail -n 2  |sed 's/\t//g' | awk '{print $3}' | sed 's/\n//g' | head -n 1`


echo "Flume Status: $flume_status"
if [ "$flume_status" == "ERROR" ]; then
	exit 2
else
	exit 0
fi
