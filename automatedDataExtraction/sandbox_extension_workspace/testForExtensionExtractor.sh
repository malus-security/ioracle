#!/bin/bash
#I'm assuming the person running this script has a jailbroken device that is connected to over ssh.

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
#not all of these are relevant in this test.
#it was copied from the dataExtractorForConnectedDevice.sh
mkdir $5/fileSystem
mkdir $5/prologFacts
mkdir $5/temporaryFiles
tempDir="/temporaryDirectoryForiOracleExtraction"

#load the sbtool executable onto the iOS device and store it in a temporary directory so it doesn't overwrite anything sensitive.
scp -q -P $port sbtool64 $user@$host:$tempDir/sbtool64
echo extracting sandbox extension data
#run the sbtool_ext.sh which tells the iOS device to run sbtool on each process id number.
#it will also do some filtering of the results, but the resulting data still needs to be converted to prolog facts by parse_sandbox_extensions.py.
#results of sbtool_ext.sh are stored in raw_sandbox_extensions.out
time ssh -p $port $user@$host 'bash -s' < sbtool_ext.sh > $directoryForOutput/temporaryFiles/raw_sandbox_extensions.out

