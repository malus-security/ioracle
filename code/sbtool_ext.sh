#!/bin/bash

for i in `ps -A -o pid=`; do
	TMP=`./sbtool $i inspect`
	echo $TMP | grep "Container:"
	if [ $? == 0 ]; then
		PID=`echo $TMP | head -1 | tr ' ' '\n' | sed -n -e 2p`
		echo "$TMP" > ext.$PID
	fi
done
