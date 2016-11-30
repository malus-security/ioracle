#!/bin/bash

IFS=$'\n'

regex="([^:]*):([^:]*):([^:]*):([^:]*):([^:]*):([^:]*):([^:]*)"
for groupEntry in `cat passwd | grep '^[^#]'`
do
  if [[ $groupEntry =~ $regex ]]
    then
      match1="${BASH_REMATCH[1]}"
      userName=`echo "$match1" | sed 's/^/userName("/' | sed 's/$/"),/'`
      match2="${BASH_REMATCH[2]}"
      passwordHash=`echo "$match2" | sed 's/^/passwordHash("/' | sed 's/$/"),/'`
      match3="${BASH_REMATCH[3]}"
      userID=`echo "$match3" | sed 's/^/userID("/' | sed 's/$/"),/'`
      match4="${BASH_REMATCH[4]}"
      groupID=`echo "$match4" | sed 's/^/groupID("/' | sed 's/$/"),/'`
      match5="${BASH_REMATCH[5]}"
      comment=`echo "$match5" | sed 's/^/comment("/' | sed 's/$/"),/'`
      match6="${BASH_REMATCH[6]}"
      homeDirectory=`echo "$match6" | sed 's/^/homeDirectory("/' | sed 's/$/"),/'`
      match7="${BASH_REMATCH[7]}"
      shell=`echo "$match7" | sed 's/^/shell("/' | sed 's/$/")/'`

      echo "user($userName$passwordHash$userID$groupID$comment$homeDirectory$shell)."

      #the following line tries to echo * which lists all the files in the current directory. 
      #Adding quotes lets specifies that we want to output just the *.
      #echo $match2
      #what do the curly brackets do to the variable in bash?
      #name="${name}.jpg"    # same thing stored in a variable

    else
      echo "$groupEntry doesn't match" >&2 # this could get noisy if there are a lot of non-matching files
  fi
done
