#!/bin/bash


if test $# -ne 4; then
	echo "Usage: $0 userOniOSDevice hostOfiOSdevice portForiOSDevice directoryForOutput" 1>&2
	echo "Example: $0 root localhost 2270 directoryForOutput" 1>&2
	exit 1
fi

user="$1"
host="$2"
port="$3"
directoryForOutput="$4"

# start interval_probe.sh in the background
start_interval_probe_cmd="./interval_probe.sh $user $host $port $directoryForOutput"
$start_interval_probe_cmd > /dev/null 2>&1 &

# start filemon_host.sh in the background
start_filemon_cmd="./filemon_host.sh $user $host $port $directoryForOutput"
$start_filemon_cmd > /dev/null 2>&1 &

<<COMM
read -rsp $'Data is being generated. Press any key to finish...\n' -n1 key

if [ -d /proc/$filemon_pid ]
then
  kill $filemon_pid
  ssh -p $port $user@$host "killall filemon"
fi

if [ -d /proc/$interval_probe_pid ]
then
  kill $interval_probe_pid
fi
COMM
