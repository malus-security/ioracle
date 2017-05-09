#!/bin/bash

##############################################################################
# The script parses the output from filemon and creates prolog facts that
# contains the mapping of process-file-operationType
##############################################################################
IFS=$'\n'

for fileAccessEntry in $(cat iOracle.out); do
  processId=`echo $fileAccessEntry | awk '{print $1}'`
  pathToProcessExecutable=`cat pid_uid_gid_comm.out | grep -w $processId | awk '{print $4}'`
  processName=`echo $fileAccessEntry | cut -d$'\t' -f1 | awk '{print substr($0, index($0, $2))}'`

  # Process name has two words
  if [[ `echo $processName | wc -w` == 2 ]]; then
    operationType=`echo $fileAccessEntry | awk '{print $4}'`
    pathToSourceFile=`echo $fileAccessEntry | awk '{print substr($0, index($0, $5))}' | cut -d$'\t' -f1 | xargs`
    pathToDestinationFile=`echo $fileAccessEntry | awk '{print substr($0, index($0, $5))}' | cut -d$'\t' -f2 | xargs`

    # Operation with multiple words; ex:"Changed xattr/stat"
    if [[ $operationType == "Changed" ]]; then
      operationType=`echo $fileAccessEntry | awk '{print $4" "$5}'`
      pathToSourceFile=`echo $fileAccessEntry | awk '{print substr($0, index($0, $6))}' | cut -d$'\t' -f1 | xargs`
      pathToDestinationFile=`echo $fileAccessEntry | awk '{print substr($0, index($0, $6))}' | cut -d$'\t' -f2 | xargs`
    fi

    # Operation "Created dir"
    if [[ `echo $fileAccessEntry | awk '{print $4" "$5}'` == "Created dir" ]]; then
      operationType=`echo $fileAccessEntry | awk '{print $4" "$5}'`
      pathToSourceFile=`echo $fileAccessEntry | awk '{print substr($0, index($0, $6))}' | cut -d$'\t' -f1 | xargs`
      pathToDestinationFile=`echo $fileAccessEntry | awk '{print substr($0, index($0, $6))}' | cut -d$'\t' -f2 | xargs`
    fi

  else # Process name has one word
    operationType=`echo $fileAccessEntry | awk '{print $3}'`
    pathToSourceFile=`echo $fileAccessEntry | awk '{print substr($0, index($0, $4))}' | cut -d$'\t' -f1 | xargs`
    pathToDestinationFile=`echo $fileAccessEntry | awk '{print substr($0, index($0, $4))}' | cut -d$'\t' -f2 | xargs`

    # Operation with multiple words; ex:"Changed xattr/stat"
    if [[ $operationType == "Changed" ]]; then
      operationType=`echo $fileAccessEntry | awk '{print $3" "$4}'`
      pathToSourceFile=`echo $fileAccessEntry | awk '{print substr($0, index($0, $5))}' | cut -d$'\t' -f1 | xargs`
      pathToDestinationFile=`echo $fileAccessEntry | awk '{print substr($0, index($0, $5))}' | cut -d$'\t' -f2 | xargs`
    fi

    # Operation "Created dir"
    if [[ `echo $fileAccessEntry | awk '{print $3" "$4}'` == "Created dir" ]]; then
      operationType=`echo $fileAccessEntry | awk '{print $3" "$4}'`
      pathToSourceFile=`echo $fileAccessEntry | awk '{print substr($0, index($0, $5))}' | cut -d$'\t' -f1 | xargs`
      pathToDestinationFile=`echo $fileAccessEntry | awk '{print substr($0, index($0, $5))}' | cut -d$'\t' -f2 | xargs`
    fi
  fi

  # Destination file does not exist -> write dummy text
  if [[ -z $pathToDestinationFile ]]; then
    pathToDestinationFile=`echo No destination`
  fi
  user=`cat pid_uid_gid_comm.out | grep -w $processId | awk '{print $2}'`
  group=`cat pid_uid_gid_comm.out | grep -w $processId | awk '{print $3}'`

  # Write the facts to file
  echo "fileAccessObservation(process(\"$pathToProcessExecutable\"),sourceFile(\"$pathToSourceFile\"),destinationFile(\"$pathToDestinationFile\"),operation(\"$operationType\"), user(\"$user\"), group(\"$group\"))."
done
