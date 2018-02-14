#!/bin/bash

IFS=$'\n'

for file in $(find / -type f); do
    /usr/bin/otool -h "$file" 2> /dev/null | grep '0xfeedfac' > /dev/null 2>&1
    if test $? -ne 0; then
        continue
    fi
    echo "$file"
done
