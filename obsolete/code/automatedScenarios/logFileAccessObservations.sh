#!/bin/bash

##############################################################################
# This script is executed on the device
# It assumes that the file /tmp/filemonRawOutput.txt was created previously
# It outputs the results to STDOUT
# The script parses the output from filemon(/tmp/filemonRawOutput.txt and
# creates prolog facts that contains the mapping of process-file-operationType
##############################################################################
IFS=$'\n'
numberOfOperations=1

while true
do
    # This is one access; The N'th entry in filemonRawOutput.txt
    fileAccessEntry=$(sed "${numberOfOperations}q;d" /tmp/filemonRawOutput.txt)

    # Save details regarding that access
    processId=`echo $fileAccessEntry | awk '{print $1}'`
    operationType=`echo $fileAccessEntry | awk '{print $3}'`
    pathToSourceFile=`echo $fileAccessEntry | awk '{print $4}'`
    pathToDestinationFile=`echo $fileAccessEntry | awk '{print $5}'`

    ((numberOfOperations++))

    # ProcessId not found
    if [[ -z $processId ]]; then
      continue
    fi

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

    # Get path to the binary that started the process
    pathToProcessExecutable=`ps -p $processId -o comm | sed -n 2p`
    user=`ps -p $processId -o user | sed -n 2p`
    groupId=`ps -p $processId -o gid | sed -n 2p | xargs`
    group=`cat /etc/group | grep :$groupId: | cut -d ":" -f1`

    # Write the facts to file
    echo "fileAccessObservation(process(\"$pathToProcessExecutable\"),sourceFile(\"$pathToSourceFile\"),destinationFile(\"$pathToDestinationFile\"),operation(\"$operationType\"), user(\"$user\"), group(\"$group\"))." 2> /dev/null
done
