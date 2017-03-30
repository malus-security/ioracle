#!/bin/bash

IFS=$'\n'
regex="([^:]*):([^:]*):([^:]*):([^:]*):([^:]*):([^:]*):([^:]*)"

# Get users from /etc/passwd
for userEntry in $(cat /etc/passwd | grep '^[^#]'); do
  if [[ $userEntry =~ $regex ]]
    then
      match1="${BASH_REMATCH[1]}"
      userName=`echo "$match1" | sed 's/^/user("/' | sed 's/$/"),/'`
      IFS=$' '
      # Get the groups
      for groupEntry in $(echo `groups $match1` | cut -d ":" -f2); do
        groupName=`echo "$groupEntry" | tr -d '[ ]' | sed 's/^/group("/' | sed 's/$/"),/'`
        # Get the id from /etc/group
        id=`cat /etc/group | grep "^$groupEntry:" | cut -d ":" -f3`
        groupId=`echo "$id" | sed 's/^/groupIDNumber("/' | sed 's/$/")/'`
        echo "groupMembership($userName$groupName$groupId)."
      done
    else
      echo "$userEntry doesn't match" >&2 # this could get noisy if there are a lot of non-matching files
  fi
done
