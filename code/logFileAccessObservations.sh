#!/bin/bash

##############################################################################
# This script is execute on the device
# It assumes that the file /tmp/filemonRawOutput.txt was created previously
# It outputs the results to STDOUT
# The script parses the output from filemon and creates prolog facts that
# contains the mapping of process-file-operationType
##############################################################################
IFS=$'\n'

for fileAccessEntry in $(cat /tmp/filemonRawOutput.txt); do
  processId=`echo $fileAccessEntry | awk '{print $1}'`
  processName=`echo $fileAccessEntry | awk '{print $2}'`

  # Get path to the binary that started the process
  pathToProcessExecutable=`ps -p $processId -o comm | sed -n 2p`
  operationType=`echo $fileAccessEntry | awk '{print $3}'`
  pathToSourceFile=`echo $fileAccessEntry | awk '{print $4}'`
  pathToDestinationFile=`echo $fileAccessEntry | awk '{print $5}'`

  # Operation with multiple words; ex:"Changed xattr/stat"
  if [[ $operationType == "Changed" ]]; then
    operationType=`echo $fileAccessEntry | awk '{print $3" "$4}'`
    pathToSourceFile=`echo $fileAccessEntry | awk '{print $5}'`
    pathToDestinationFile=`echo $fileAccessEntry | awk '{print $6}'`
  fi

  # Destination file does not exist -> write dummy text
  if [[ -z $pathToDestinationFile ]]; then
    pathToDestinationFile=`echo No destination`
  fi

  # Write the facts to file
  echo "fileAccessObservation(process(\"$pathToProcessExecutable\"),sourceFile(\"$pathToSourceFile\"),destinationFile(\"$pathToDestinationFile\"),operation(\"$operationType\"))."
done
