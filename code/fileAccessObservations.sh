#!/bin/bash

#    This file uses filemon to collect Process-File-Operation facts.
#    Run script and wait for Workflow app to start on the device. This will
# generate actions on the device so processes will open files.
#    This scripts assumes that ./filemon is in /home/root and Workflow app is
# installed. Also the device is jailbroken and connected over ssh.

source utils

if test $# -ne 5; then
	echo "Usage: $0 userOniOSDevice hostOfiOSdevice portForiOSDevice directoryForOutput timeSpent" 1>&2
	echo "Example: $0 root localhost 2270 extractediOSFileSystem 60" 1>&2
	echo "WARNING: This script will sudo rm -rf the directory at the path of directoryForOutput" 1>&2
	exit 1
fi

user="$1"
host="$2"
port="$3"
directoryForOutput="$4"
timeSpent="$5"
filemonPath="/var/root/filemon"

echo Starting filemon
echo Please use device to generate file acesses
executeCommandUntilKeyPressed "ssh -p $port -n $user@$host $filemonPath" $timeSpent > $directoryForOutput/filemonRawOutput.txt
