#!/bin/bash

##############################################################################
# The script parses the output of ps  and creates prolog facts that
# contains the mapping of uid, pid, comm
##############################################################################
IFS=$'\n'

outputFileSystem="$1/fileSystem"
outputPrologFacts="$1/prologFacts"



for process in $(sort -u -k3 $outputFileSystem/pid_uid_gid_comm.out); do
  user=`echo $process | awk '{print $2}'`
  group=`echo $process | awk '{print $3}'`
  comm=`echo $process | awk '{print $4}'`
  if [[ $user == UID ]]; then
    continue
  fi
  echo "processOwnership(uid(\"$user\"),gid(\"$group\"),comm(\"$comm\"))." >> $outputPrologFacts/processOwnershipFacts.pl
done
