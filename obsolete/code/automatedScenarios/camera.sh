#!/bin/bash

##############################################################################
# You need an app called "activator" from cydia in order to run the script   #
##############################################################################

if test $# -ne 3; then
	echo "Usage: $0 userOniOSDevice hostOfiOSdevice portOfiOSdevice" 1>&2
	echo "Example: $0 root localhost 22" 1>&2
	exit 1
fi


user="$1"
host="$2"
port="$3"

echo "Take Photo"
ssh -p $port -n $user@$host "activator send 'libactivator.shortcut:com.apple.camera:Take Selfie'"
sleep 2
ssh -p $port -n $user@$host activator send libactivator.camera.invoke-shutter

sleep 2

echo "Record Video"
ssh -p $port -n $user@$host "activator send 'libactivator.shortcut:com.apple.camera:Record Video'"
sleep 2
ssh -p $port -n $user@$host activator send libactivator.camera.invoke-shutter
sleep 5
ssh -p $port -n $user@$host activator send libactivator.camera.invoke-shutter
