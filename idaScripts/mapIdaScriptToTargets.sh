#!/bin/bash

if [ "$1" == "-h" ] || [ "$#" -ne 5 ]; then
  echo "Error: Invalid Arguments"
  echo "This script takes 4 arguments and its purpose is to run an idascript on several disassembled executables."
  echo "Usage: ./$0 mappingOfNamesAndPaths idapythonScript directoryHoldingIDADatabases/ pathToOutputFile configFileForIDAscript"
  exit 0
fi

mappingOfNamesAndPaths=$1
idapythonScript=$2
directoryHoldingIDADatabases=$3 
pathToOutputFile=$4
idaScriptConfigFile=$5

#deletes the file to be used as output in case it exists already and contains old results
rm $pathToOutputFile

for line in `cat $mappingOfNamesAndPaths`
do 
  #get name and path of executable to run script on
  name=`echo $line | sed 's/,.*//g'`
  path=`echo $line | sed 's/.*,//g'`

  #run the ida script
  #I should have another mode in case the binary is 32 bit
  #however the only 32 bit binaries i need to handle now are the dyld_shared_cache and the kernel which can be handled individually.
  #I could also reanalyze these using idaq64, but it would take too long, and I don't know if it would break anything...
  idal64 -S"$idapythonScript $name $path $pathToOutputFile $idaScriptConfigFile" $directoryHoldingIDADatabases$name.i64
done
