#!/bin/bash
#needs to run as root because file permissions on files extracted from iOS device will be preserved.
#I'm assuming the person running this script has a jailbroken device that can be connected to over ssh.

if test $# -ne 4; then
	echo "Usage: $0 user host sourceDirectory destinationDirectory" 1>&2
	echo "Example: $0 malus vmx.cs.pub.ro /iPhoneSE_13F69_iOS932/prologFacts /home/malus/processed-facts/iPhoneSE_13F69_iOS932" 1>&2
	exit 1
fi

user="$1"
host="$2"
sourceDirectory="$3"
destinationDirectory="$4"

#compress files into archive
tar -czvf $sourceDirectory/archivedFilesToSync.tar.gz -C $sourceDirectory .

#send archive to remote destination directory
scp $sourceDirectory/archivedFilesToSync.tar.gz "$user"@"$host":$destinationDirectory/

#extract files from archive into remote destination directory
time ssh $user@$host "tar -xzvf $destinationDirectory/archivedFilesToSync.tar.gz -C $destinationDirectory" 
