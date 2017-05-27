#!/bin/bash

#this shell script is launched from the computer connected to the iOS device.
#however the following code will run on the iOS device.
#For example, the pids listed by ps will be those on the iOS device.

#for each process id number
for i in `ps -A -o pid=`; do
	#the variable $i now contains the pid number
	#run sbtool on the pid and use the 'inspect' option.
	#we should have already loaded sbtool onto the device using a previous script.
	#suppress errors by sending them to /dev/null
	#use echo to get all the output for one process onto one line
	#grep "extensions" only keeps the output for processes that have sandbox extensions
	echo $(/private/var/mobile/temporaryDirectoryForiOracleExtraction/sbtool64 $i inspect 2> /dev/null) | grep "extensions ("
done
