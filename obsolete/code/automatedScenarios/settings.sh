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

echo "Start Toggling in Settings"
ssh -p $port -n $user@$host activator send switch-flip.com.a3tweaks.switch.autolock
sleep 2
ssh -p $port -n $user@$host activator send switch-flip.com.a3tweaks.switch.bluetooth
sleep 2
#ssh -p $port -n $user@$host activator send switch-flip.com.a3tweaks.switch.wifi
sleep 2
ssh -p $port -n $user@$host activator send switch-flip.com.a3tweaks.switch.location
sleep 2
ssh -p $port -n $user@$host activator send switch-flip.com.a3tweaks.switch.ringer
sleep 2
ssh -p $port -n $user@$host activator send switch-flip.com.a3tweaks.switch.rotation
sleep 2
ssh -p $port -n $user@$host activator send switch-flip.com.a3tweaks.switch.night-shift
sleep 2
ssh -p $port -n $user@$host activator send switch-flip.com.a3tweaks.switch.cellular-data
sleep 2
ssh -p $port -n $user@$host activator send switch-flip.com.a3tweaks.switch.flashlight
sleep 2
ssh -p $port -n $user@$host activator send switch-flip.com.a3tweaks.switch.rotation-lock
sleep 2
ssh -p $port -n $user@$host activator send switch-flip.com.a3tweaks.switch.vibration
sleep 2
ssh -p $port -n $user@$host activator send switch-flip.com.a3tweaks.switch.do-not-disturb
sleep 2
ssh -p $port -n $user@$host activator send switch-flip.com.a3tweaks.switch.low-power
sleep 2
ssh -p $port -n $user@$host activator send switch-flip.com.a3tweaks.switch.airplane-mode
sleep 2
ssh -p $port -n $user@$host activator send switch-flip.com.a3tweaks.switch.vpn
sleep 2
ssh -p $port -n $user@$host activator send switch-flip.com.a3tweaks.switch.lte
sleep 2
ssh -p $port -n $user@$host activator send switch-flip.com.a3tweaks.switch.autolock
sleep 2
ssh -p $port -n $user@$host activator send switch-flip.com.a3tweaks.switch.hotspot
sleep 2
ssh -p $port -n $user@$host activator send switch-flip.com.a3tweaks.switch.auto-brightness
sleep 2
