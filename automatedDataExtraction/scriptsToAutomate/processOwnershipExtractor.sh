#!/bin/bash

ps -e -o uid,gid,comm | /temporaryDirectoryForiOracleExtraction/tail -n +2 | /temporaryDirectoryForiOracleExtraction/tr -s ' ' | while read uid gid comm; do
	echo "processOwnership(uid(\"$uid\"),gid(\"$gid\"),comm(\"$comm\"))."
done
