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

#we can store binary files in this directory to reduce the chances of clobbering existing files
mkdir $5/temporaryFiles
tempDir="/temporaryDirectoryForiOracleExtraction"


echo extracting file system
time ssh -p $port -n $user@$host "tar zcf - $downloadDirectory" > $directoryForOutput/fileSystem.tar.gz

#extract meta data. This asks for the password again, but it's not a big deal.
echo extracting file metadata
time ssh -p $port $user@$host 'bash -s' < ./scriptsToAutomate/metaDataExtractor.sh $downloadDirectory | sort | uniq > $directoryForOutput/prologFacts/unsanitized_file_metadata.pl
time ./scriptsToAutomate/sanitizeFilePaths.py $directoryForOutput/prologFacts/unsanitized_file_metadata.pl > $directoryForOutput/prologFacts/file_metadata.pl

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
time ssh -p $port $user@$host 'bash -s' < ./scriptsToAutomate/extractACL.sh $downloadDirectory > $directoryForOutput/temporaryFiles/aclOutput.out
#It's possible that there simply isn't any ACL data on the filesystem. This seems to be common for iOS versions prior to 9.
#I should have a condition to state when this seems to happen instead of letting the python script freak out and throw an error.
#For compatibility, I create a fact that always fails if matched. This should be semantically equivalent to having none of these facts.
#However, prolog will still look for the facts, and we want it to fail to unify instead of crashing or throwing an error.
echo parsing posix ACL data into prolog facts
aclLineCount=`cat $directoryForOutput/temporaryFiles/aclOutput.out | wc -l`
if [ "$aclLineCount" -eq 0 ]
then
  #since there are no ACL facts, any attempt to match one should fail.
  fastFailFact='fileACL( _, _, _, _, _, _, _) :- fail.'
  time echo $fastFailFact > $directoryForOutput/prologFacts/aclFacts.pl
else
  time ./scriptsToAutomate/parseACLs.py $directoryForOutput/temporaryFiles/aclOutput.out > $directoryForOutput/prologFacts/aclFacts.pl
fi

#Extract groups from all users
#TODO sanity check this new stuff
scp -q -P $port ./scriptsToAutomate/groupFactExtractorFromUsers.sh $user@$host:$tempDir/groupFactExtractorFromUsers.sh
time ssh -p $port $user@$host $tempDir/groupFactExtractorFromUsers.sh > $directoryForOutput/prologFacts/dynamicGroups.pl
