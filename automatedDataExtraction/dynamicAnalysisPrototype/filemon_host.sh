#!/bin/bash
#I'm assuming the person running this script has a jailbroken device that is connected to over ssh.

if test $# -ne 4; then
	echo "Usage: $0 userOniOSDevice hostOfiOSdevice portForiOSDevice" 1>&2
	echo "Example: $0 root localhost 2270 directoryForOutput" 1>&2
	exit 1
fi

user="$1"
host="$2"
port="$3"
directoryForOutput="$4"

tempDir="/temporaryDirectoryForiOracleExtraction"

#load the filemon executable onto the iOS device and store it in a temporary directory so it doesn't overwrite anything sensitive.
scp -q -P $port ./filemon/filemon $user@$host:$tempDir/filemon

#start running filemon while writing data to the host.
time ssh -p $port $user@$host 'bash -s' < filemon_device.sh 
