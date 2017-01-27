#!/bin/bash

ps -e -o uid,gid,comm | tail -n +2 | tr -s ' ' | while read uid gid comm; do
	echo "processOwnership(uid($uid),gid($gid),comm(\"$comm\"))."
done
