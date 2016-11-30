#!/bin/bash

IFS=$'\n'

regex="([^\ 	]*)[\ 	]*([^\/]*)\/([^\ 	#]*)[#\ 	]*(.*)[\ 	]*$"
for serviceEntry in `cat ../nonPrologData/network/services | grep '^[^#]'`
do
  if [[ $serviceEntry =~ $regex ]]
    then
      match1="${BASH_REMATCH[1]}"
      serviceName=`echo "$match1" | sed 's/^/serviceName("/' | sed 's/$/"),/'`
      match2="${BASH_REMATCH[2]}"
      portNumber=`echo "$match2" | sed 's/^/portNumber("/' | sed 's/$/"),/'`
      match3="${BASH_REMATCH[3]}"
      protocol=`echo "$match3" | sed 's/^/protocol("/' | sed 's/$/"),/'`
      match4="${BASH_REMATCH[4]}"
      comment=`echo "$match4" | sed 's/^/comment("/' | sed 's/,/","/g' | sed 's/$/")/'`

      echo "service($serviceName$portNumber$protocol$comment)."

      #the following line tries to echo * which lists all the files in the current directory. 
      #Adding quotes lets specifies that we want to output just the *.
      #echo $match2
      #what do the curly brackets do to the variable in bash?
      #name="${name}.jpg"    # same thing stored in a variable

    else
      echo "$serviceEntry doesn't match" >&2 # this could get noisy if there are a lot of non-matching files
  fi
done
