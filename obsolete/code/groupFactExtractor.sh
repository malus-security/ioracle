#!/bin/bash

if test $# -ne 1; then
	echo "Usage: $0 /path/to/root/filesystem/" 1>&2
	exit 1
fi

rootfs_path="$1"

#the find command also has a printf option and provides much of the same data as stat
IFS=$'\n'

regex="([^:]*):([^:]*):([^:]*):([^:]*)"
for groupEntry in $(cat "$rootfs_path"/etc/group | grep '^[^#]'); do
  if [[ $groupEntry =~ $regex ]]
    then
      match1="${BASH_REMATCH[1]}"
      groupName=`echo "$match1" | sed 's/^/groupName("/' | sed 's/$/"),/'`
      match2="${BASH_REMATCH[2]}"
      passwordHash=`echo "$match2" | sed 's/^/passwordHash("/' | sed 's/$/"),/'`
      match3="${BASH_REMATCH[3]}"
      id=`echo "$match3" | sed 's/^/id("/' | sed 's/$/"),/'`
      match4="${BASH_REMATCH[4]}"
      members=`echo "$match4" | sed 's/^/members(["/' | sed 's/,/","/g' | sed 's/$/"])/'`

      echo "group($groupName$passwordHash$id$members)."

      #the following line tries to echo * which lists all the files in the current directory. 
      #Adding quotes lets specifies that we want to output just the *.
      #echo $match2
      #what do the curly brackets do to the variable in bash?
      #name="${name}.jpg"    # same thing stored in a variable

    else
      echo "$groupEntry doesn't match" >&2 # this could get noisy if there are a lot of non-matching files
  fi
done
