#!/bin/bash

if test $# -ne 1; then
	echo "Usage: $0 /path/to/root/filesystem/" 1>&2
	exit 1
fi

rootfs_path="$1"

find "$rootfs_path" -printf 'fileSize(size(%s),filepath("%p")).\nfileOwnerGroupName(ownerGroupName("%g"),filepath("%p")).\nfileLastModification(lastModification(%T@),filepath("%p")).\nfileInode(inode(%i),filepath("%p")).\nfileSymLink(symLinkObject("%l"),filepath("%p")).\nfilePermissionBits(permissionBits(%m),filepath("%p")).\nfileNumHardLinks(numHardLinks(%n),filepath("%p")).\nfileOwnerUserName(ownerUserName("%u"),filepath("%p")).\nfileType(type("%y"),filepath("%p")).\n'
