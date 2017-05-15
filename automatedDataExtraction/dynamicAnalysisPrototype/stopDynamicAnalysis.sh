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
tempDir="/temporaryDirectoryForiOracleExtraction"

# stop interval_probe.sh
get_pid_interval_probe_cmd=`ps aux | grep interval | grep $2 | awk '{ print $2 }'`
`kill -9 $get_pid_interval_probe_cmd`

# stop filemon_host.sh
get_pid_filemon_cmd=`ps aux | grep filemon | grep $2 | awk '{ print $2 }'`
`kill -9 $get_pid_filemon_cmd`

scp -q -P $port $user@$host:$tempDir/iOracle.out $4/fileSystem/iOracle.out

ssh -p $port $user@$host 'killall filemon'
ssh -p $port $user@$host 'killall sbtool64'
ssh -p $port $user@$host "rm -rf $tempDir"
