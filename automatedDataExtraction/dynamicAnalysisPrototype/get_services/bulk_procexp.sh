#!/bin/bash

#this shell script is launched from the computer connected to the iOS device.
#however the following code will run on the iOS device.
#For example, the pids listed by ps will be those on the iOS device.

tempDir="/private/var/mobile/temporaryDirectoryForiOracleExtraction"

#for each process id number

for i in `ps -A -o pid=`; do

	#the variable $i now contains the pid number
	#run procexp on the pid and grep for \" (escaped double quote) to show only mach-port information.
	#we should have already loaded procexp onto the device using a previous script.
	#suppress errors by sending them to /dev/null
	#use echo to get all the output for one process onto one line
	#echo $(/var/mobile/luke_procexp_tests/procexp.universal $i | grep \" 2> /dev/null)

	$tempDir/procexp.universal $i | grep \" 2> /dev/null

done
