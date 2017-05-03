#!/bin/bash

#for each process id number
for i in `ps -A -o pid=`; do
	#run sbtool inspect on it.
	#suppress errors by sending them to /dev/null
	#use echo to get all the output for one process onto one line
	#grep "extensions" only keeps the output for processes that have sandbox extensions
	#echo $(./sbtool $i inspect 2> /dev/null) | grep "extensions ("
	echo $(/temporaryDirectoryForiOracleExtraction/sbtool64 $i inspect 2> /dev/null) | grep "extensions ("
done
