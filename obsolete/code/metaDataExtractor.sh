#!/bin/bash

if test $# -ne 1; then
	echo "Usage: $0 /path/to/root/filesystem/" 1>&2
	exit 1
fi

rootfs_path="$1"

find "$rootfs_path" -printf 'file(filepath("%p"),size(%s)).\nfile(filepath("%p"),ownerGroupName("%g")).\nfile(filepath("%p"),lastModification(%T@)).\nfile(filepath("%p"),inode(%i)).\nfile(filepath("%p"),symLinkObject("%l")).\nfile(filepath("%p"),permissionBits(%m)).\nfile(filepath("%p"),numHardLinks(%n)).\nfile(filepath("%p"),ownerUserName("%u")).\nfile(filepath("%p"),type("%y")).\n'
