#!/bin/bash
#needs to run as root because file permissions on files extracted from iOS device will be preserved.
#I'm assuming the person running this script has a jailbroken device that can be connected to over ssh.

if test $# -ne 5; then
	echo "Usage: $0 userOniOSDevice hostOfiOSdevice portForiOSDevice directoryToDownload directoryForOutput" 1>&2
	echo "Example: $0 root localhost 2270 / extractediOSFileSystem" 1>&2
	echo "WARNING: This script will sudo rm -rf the directory at the path of directoryForOutput" 1>&2
	exit 1
fi

user="$1"
host="$2"
port="$3"
downloadDirectory="$4"
directoryForOutput="$5"

rm -rf ./$5
mkdir $5
mkdir $5/fileSystem
mkdir $5/prologFacts
mkdir $5/temporaryFiles
tempDir="/temporaryDirectoryForiOracleExtraction"


#get process ownership for processes currently running on the iOS device
#we might want to set up the device such that certain devices are running, but running this naively is still useful.
scp -q -P $port ./utilities/sbtool64 $user@$host:$tempDir/sbtool64
echo extracting sandbox extension data
time ssh -p $port $user@$host 'bash -s' < ./scriptsToAutomate/sbtool_ext.sh > $directoryForOutput/temporaryFiles/raw_sandbox_extensions.out

