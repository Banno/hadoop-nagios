#!/bin/bash

okay_exit=0
warning_exit=1
critical_exit=2
unk_exit=3

if [ -z "$1" ]; then
  echo "Warning / Critical undefined!"
  echo "Usage: $0 warning-nuber critical-number"
  exit $unk_exit
fi

warning=$1
critical=$2

if [ ! $critical -ge $warning ]; then
  echo "Critical must be >= Warning!"
  exit $unk_exit
fi

output=`exec 3<>/dev/tcp/127.0.0.1/50030
 echo -e "GET /jobtracker.jsp HTTP/1.0\n\n" >&3
 cat <&3`


num_active_tt=`echo $output | tr ' ' '\012' | grep href=\"machines.jsp\?type=active\" | cut -d'>' -f 2 | cut -d'<' -f 1`
if [ $num_active_tt -lt $critical ]; then
  echo "CRITICAL - TackTrackers up and running: $num_active_tt"
  exit $critical_exit
elif [ $num_active_tt -lt $warning ]; then
  echo "WARNING - TaskTrackers up and running: $num_active_tt"
  exit $warning_exit
else
  echo "OK - TaskTrackers up and running: $num_active_tt"
  exit $ok_exit
fi

