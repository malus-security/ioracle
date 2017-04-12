#!/bin/bash

#    This script assumes that:
#         * filemon binary is available in /var/root/filemon and it is
#           executable
#         * a jailbroken device is available
#         * ssh connection available
#    It uses filemon to collect Process-File-Operation facts.
#    Download filemon from:
#                      wget http://newosxbook.com/tools/filemon.tgz
#    In order to authenticate via ssh keys, you can use code/authViaKeys.sh
# so you don't have to provide the password anymore. [ OPTIONAL ]
#    Run script and generate actions on the device so processes will open
# files.

source utils

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
workdir="/private/var/tmp/"

ssh -p $port -n $user@$host "test -e $filemonPath"
if [ ! $? -eq 0 ]; then
    echo "Filemon not found! Please download it and retry."
    exit 0
fi


rm -rf ./$directoryForOutput
mkdir $directoryForOutput

echo Please use device to generate file acesses
executeCommandUntilKeyPressed "ssh -p $port -n $user@$host $filemonPath > $workdir/filemonRawOutput.txt"

echo Generating the facts...
time ssh -p $port $user@$host 'bash -s' < logFileAccessObservations.sh > $directoryForOutput/fileAccessObservations.pl

# Clean up
ssh -p $port $user@$host rm $workdir/filemonRawOutput.txt
