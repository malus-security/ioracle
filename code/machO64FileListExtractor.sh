#!/bin/bash

IFS=$'\n'

count=0
echoerr()
{
    echo "$@" 1>&2
}
echoerr $count

for file in $(find / -type f); do
    count=$((count + 1))
    if ! (("$count" % 1000)); then
        echoerr "$count"
    fi
    /usr/bin/otool -h "$file" 2> /dev/null | grep '0xfeedfacf' > /dev/null 2>&1
    if test $? -ne 0; then
        continue
    fi
    echo "$file"
done
