#!/bin/bash


if test $# -ne 4; then
	echo "Usage: $0 userOniOSDevice hostOfiOSdevice portForiOSDevice directoryForOutput" 1>&2
	echo "Example: $0 root localhost 2270 directoryForOutput" 1>&2
	echo "WARNING: This script will rm -rf the directoryForOutput. Please be careful!" 1>&2
	exit 1
fi

user="$1"
host="$2"
port="$3"
directoryForOutput="$4"
tempDir="/private/var/mobile/temporaryDirectoryForiOracleExtraction"

rm -rf $4
mkdir $4
mkdir $4/fileSystem
mkdir $4/prologFacts
mkdir $4/temporaryFiles

ssh -p $port $user@$host mkdir $tempDir

# start interval_probe.sh in the background
start_interval_probe_cmd="./interval_probe.sh $user $host $port $directoryForOutput"
$start_interval_probe_cmd > /dev/null 2>&1 &

# start filemon_host.sh in the background
start_filemon_cmd="./filemon_host.sh $user $host $port $directoryForOutput"
$start_filemon_cmd > /dev/null 2>&1 &

echo "filemon and sbtool started in the background. You can start doing the scenarios."
echo "Once you finish, please run stopDynamicAnalysis.sh"
