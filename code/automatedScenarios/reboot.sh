#!/bin/bash

##############################################################################
# You need an app called "activator" from cydia in order to run the script   #
##############################################################################

source ../utils

if test $# -ne 4; then
	echo "Usage: $0 userOniOSDevice hostOfiOSdevice portForiOSDevice directoryForOutput" 1>&2
	echo "Example: $0 root localhost 2270 extractediOSFileSystem" 1>&2
	echo "WARNING: This script will sudo rm -rf the directory at the path of directoryForOutput" 1>&2
	exit 1
fi

user="$1"
host="$2"
port="$3"
directoryForOutput="$4"
filemonPath="/var/root/filemon"
filemonOutput="/tmp/filemonRawOutput.txt"
startupScript="com.iOracle.filemon.loader.plist"
daemonsPath="/Library/LaunchDaemons/"

# Check if filemon is present
ssh -p $port -n $user@$host "test -e $filemonPath"
if [ ! $? -eq 0 ]; then
    echo "Filemon not found! Please download it and retry."
    exit 0
fi
<<COMM
rm -rf ./$directoryForOutput
mkdir $directoryForOutput

# Prerequisites: clean up the system (procs + files)
ssh -p $port $user@$host "killall filemon"
ssh -p $port $user@$host "rm $filemonOutput"

# Inject the script that will start filemon at startup
scp -q -P $port $startupScript $user@$host:$daemonsPath

# Reboot device
ssh -p $port $user@$host reboot

# Wait for the device to reboot
while ping -c 1 $host &>/dev/null; do :; done
while ! ping -c 1 $host &>/dev/null; do :; done
COMM
# Create pl facts while booting
time ssh -p $port $user@$host 'bash -s' < logFileAccessObservations.sh > $directoryForOutput/fileAccessObservations.pl


# Clean up the device
ssh -p $port $user@$host "rm $daemonsPath$startupScript"
ssh -p $port $user@$host "rm $filemonRawOutput.txt"
ssh -p $port $user@$host "killall filemon"
