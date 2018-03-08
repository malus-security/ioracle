#!/bin/bash

if test $# -ne 1; then
	echo "Usage: $0 /path/to/root/filesystem/" 1>&2
	exit 1
fi

rootfs_path="$1/"
rootfs_path=${rootfs_path//\/\//\/}

IFS=$'\n'

echoerr() { echo "$@" 1>&2; }

while read line; do
    filePath="$rootfs_path$line"

    #./tools/jtool/jtool -arch armv7 --ent $filePath 2>&1
    mig_systems=`./tools/jtool/jtool -d __DATA.__const $filePath | grep "MIG subsy" 2>&1` ;
    #-z checks to see if the string is empty.
    if [ ! -z "$mig_systems" ]; then
      mig_lines=`echo "$mig_systems"`
      for mig in $mig_lines;
      do
        #I need to parse the mig findings from jtool into the address of the subsystem and the number of messages
        mig_address=`echo $mig | sed 's/:.*$//'`
        mig_num_messages=`echo $mig | sed 's/^.*(//' | sed 's/\ messages.*$//'`
        echo "mach_interface(type('MIG'),filePath('$line'),address('$mig_address'),num_messages($mig_num_messages))."
      done
    fi;
done
