#!/bin/bash

if test $# -ne 1; then
	echo "Usage: $0 /path/to/root/filesystem/" 1>&2
	exit 1
fi

directoryToAnalyze="$1"

#determine if the device is 64 bit or not
processorType=`uname -p`
if [[ $processorType == *"64"* ]]; then
  find $directoryToAnalyze -exec /temporaryDirectoryForiOracleExtraction/getfacl_arm64 {} \; 2> /dev/null
else
  find $directoryToAnalyze -exec /temporaryDirectoryForiOracleExtraction/getfacl_armv7 {} \; 2> /dev/null
fi

#run appropriate version of getfacl
#find / -exec ./getfacl {} \; > aclOutput.out 2> /dev/null
