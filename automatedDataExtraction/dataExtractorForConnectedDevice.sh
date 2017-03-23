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

echo extracting file system
time ssh -p $port -n $user@$host "tar zcf - $downloadDirectory" > $directoryForOutput/fileSystem.tar.gz

#NOTE: I am trying to avoid using sudo in this script since it requires asking for the password at an awkward time.
#sudo tar -xzf $directoryForOutput/fileSystem.tar.gz -C $directoryForOutput/fileSystem
#make the new file system owned by the current user to avoid needing sudo all the time.
#We can get the unix permissions by extracting metadata from the device, so its ok if we lose them locally.
#sudo chown -R $USER $directoryForOutput
#chmod -R 777 $directoryForOutput

#extract meta data. This asks for the password again, but it's not a big deal.
echo extracting file metadata
time ssh -p $port $user@$host 'bash -s' < ./scriptsToAutomate/metaDataExtractor.sh $downloadDirectory > $directoryForOutput/prologFacts/file_metadata.pl

#we can store binary files in this directory to reduce that chances of clobbering existing files
mkdir $5/temporaryFiles
tempDir="/temporaryDirectoryForiOracleExtraction"

#get process ownership for processes currently running on the iOS device
#we might want to set up the device such that certain devices are running, but running this naively is still useful.
scp -q -P $port ./utilities/tail $user@$host:$tempDir/tail
scp -q -P $port ./utilities/tr $user@$host:$tempDir/tr
echo extracting process ownership data
time ssh -p $port $user@$host 'bash -s' < ./scriptsToAutomate/processOwnershipExtractor.sh > $directoryForOutput/prologFacts/process_ownership.pl

#Extract and format ACL data
ssh -p $port $user@$host "mkdir $tempDir"
scp -q -P $port ./getfacl-master/getfacl_arm64 $user@$host:$tempDir/getfacl_arm64
scp -q -P $port ./getfacl-master/getfacl_armv7 $user@$host:$tempDir/getfacl_armv7
ssh -p $port $user@$host "ldid -S $tempDir/getfacl_arm64"
ssh -p $port $user@$host "ldid -S $tempDir/getfacl_armv7"
echo extracting posix ACL data
time ssh -p $port $user@$host 'bash -s' < ./scriptsToAutomate/extractACL.sh $downloadDirectory > $directoryForOutput/temporaryFiles/aclOuput.out
echo parsing posix ACL data into prolog facts
time ./scriptsToAutomate/parseACLs.py $directoryForOutput/temporaryFiles/aclOuput.out > $directoryForOutput/prologFacts/aclFacts.pl
