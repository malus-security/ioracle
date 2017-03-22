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

ssh -p $port -n $user@$host "tar zcf - $downloadDirectory" > $directoryForOutput/fileSystem.tar.gz
sudo tar -xzf $directoryForOutput/fileSystem.tar.gz -C $directoryForOutput/fileSystem

#make the new file system owned by the current user to avoid needing sudo all the time.
#We can get the unix permissions by extracting metadata from the device, so its ok if we lose them locally.
sudo chown -R $USER $directoryForOutput
chmod -R 777 $directoryForOutput

#extract meta data. This asks for the password again, but it's not a big deal.
ssh -p $port $user@$host 'bash -s' < ./scriptsToAutomate/metaDataExtractor.sh $downloadDirectory > $directoryForOutput/prologFacts/file_metadata.pl

#get process ownership for processes currently running on the iOS device
#we might want to set up the device such that certain devices are running, but running this naively is still useful.
ssh -p $port $user@$host 'bash -s' < ./scriptsToAutomate/processOwnershipExtractor.sh > $directoryForOutput/prologFacts/process_ownership.pl

#Extract and format ACL data
mkdir $5/temporaryFiles
tempDir="/temporaryDirectoryForiOracleExtraction"
ssh -p $port $user@$host "mkdir $tempDir"
scp -q -P $port ./getfacl-master/getfacl_arm64 $user@$host:$tempDir/getfacl_arm64
scp -q -P $port ./getfacl-master/getfacl_armv7 $user@$host:$tempDir/getfacl_armv7
ssh -p $port $user@$host "ldid -S $tempDir/getfacl_arm64"
ssh -p $port $user@$host "ldid -S $tempDir/getfacl_armv7"
ssh -p $port $user@$host 'bash -s' < ./scriptsToAutomate/extractACL.sh $downloadDirectory > $directoryForOutput/temporaryFiles/aclOuput.out
./scriptsToAutomate/parseACLs.py $directoryForOutput/temporaryFiles/aclOuput.out > $directoryForOutput/prologFacts/aclFacts.pl
