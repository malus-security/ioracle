#!/bin/bash
#I'm assuming the person running this script has a jailbroken device that is connected to over ssh.

if test $# -ne 4; then
	echo "Usage: $0 userOniOSDevice hostOfiOSdevice portForiOSDevice" 1>&2
	echo "Example: $0 root localhost 2270" 1>&2
	exit 1
fi

user="$1"
host="$2"
port="$3"
directoryForOutput="$4"

rm -rf ./$4
mkdir $4
#not all of these are relevant in this test.
#it was copied from the dataExtractorForConnectedDevice.sh
mkdir $4/fileSystem
mkdir $4/prologFacts
mkdir $4/temporaryFiles
tempDir="/temporaryDirectoryForiOracleExtraction"

#load the sbtool executable onto the iOS device and store it in a temporary directory so it doesn't overwrite anything sensitive.
scp -q -P $port sbtool64 $user@$host:$tempDir/sbtool64
#run the sbtool_ext.sh which tells the iOS device to run sbtool on each process id number.
#it will also do some filtering of the results, but the resulting data still needs to be converted to prolog facts by parse_sandbox_extensions.py.
#results of sbtool_ext.sh are stored in raw_sandbox_extensions.out

while true
do
  echo extracting sandbox extension data
  time ssh -p $port $user@$host 'bash -s' < sbtool_ext.sh >> raw_sandbox_extensions.out

  #output the data we need from ps
  echo extracting process ownership and pid to path data
  time ssh -p $port $user@$host 'ps -e -o pid,uid,gid,comm' >> pid_uid_gid_comm.out

  #clean up the files so they don't get too big.
  cat raw_sandbox_extensions.out | sort | uniq > sbext.uniq
  mv sbext.uniq $4/fileSystem/raw_sandbox_extensions.out

  cat pid_uid_gid_comm.out | sort | uniq > ps.uniq
  mv ps.uniq $4/fileSystem/pid_uid_gid_comm.out
done
