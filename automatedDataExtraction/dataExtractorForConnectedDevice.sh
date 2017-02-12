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
#ssh -p $port $user@$host 
ssh -p $port -n $user@$host "tar zcf - $downloadDirectory" > $directoryForOutput/fileSystem.tar.gz
sudo tar -xzf $directoryForOutput/fileSystem.tar.gz -C $directoryForOutput/fileSystem

#make the new file system owned by the current user to avoid needing sudo all the time.
#We can get the unix permissions by extracting metadata from the device, so its ok if we lose them locally.
sudo chown -R $USER $directoryForOutput

#extract meta data. This asks for the password again, but it's not a big deal.
ssh -p $port $user@$host 'bash -s' < ./scriptsToAutomate/metaDataExtractor.sh $downloadDirectory > $directoryForOutput/prologFacts/metadata_facts.pl
