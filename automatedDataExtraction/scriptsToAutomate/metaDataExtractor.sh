#!/bin/bash

if test $# -ne 1; then
	echo "Usage: $0 /path/to/root/filesystem/" 1>&2
	exit 1
fi

rootfs_path="$1/"
rootfs_path=${rootfs_path//\/\//\/}

find "$rootfs_path" -printf 'fileSize(size(%s),filePath("%p")).\nfileOwnerGroupName(ownerGroupName("%g"),filePath("%p")).\nfileLastModification(lastModification(%T@),filePath("%p")).\nfileInode(inode(%i),filePath("%p")).\nfileSymLink(symLinkObject("%l"),filePath("%p")).\nfilePermissionBits(permissionBits(%m),filePath("%p")).\nfileNumHardLinks(numHardLinks(%n),filePath("%p")).\nfileOwnerUserName(ownerUserName("%u"),filePath("%p")).\nfileType(type("%y"),filePath("%p")).\n'
