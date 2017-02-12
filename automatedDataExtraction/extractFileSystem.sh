#!/bin/bash
#needs to run as root because file permissions on files extracted from iOS device will be preserved.
#I'm assuming the person running this script has a jailbroken device that can be connected to over ssh.

if test $# -ne 5; then
	echo "Usage: $0 userOniOSDevice hostOfiOSdevice portForiOSDevice directoryToDownload nameForOutput" 1>&2
	echo "Example: $0 root localhost 2270 / extractediOSFileSystem" 1>&2
	echo "WARNING: This script will destroy the directory at the path of nameForOutput" 1>&2
	exit 1
fi

user="$1"
host="$2"
port="$3"
downloadDirectory="$4"
nameForOutput="$5"

rm -rf $5
rm $5.tar.gz
mkdir $5
#ssh -p $port $user@$host 
ssh -p $port -n $user@$host "tar zcvf - $downloadDirectory" > $nameForOutput.tar.gz
sudo tar -xzf $nameForOutput.tar.gz -C $nameForOutput
