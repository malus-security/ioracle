#!/bin/bash

if test $# -ne 1; then
	echo "Usage: $0 /path/to/root/filesystem/" 1>&2
	exit 1
fi

rootfs_path="$1/"
#this removes an extra slash at the end of the file path if I end up with one.
rootfs_path=${rootfs_path//\/\//\/}

current_dir=`pwd`
cd $rootfs_path

sudo gfind . -printf 'fileSize(size(%s),filePath("%p")).\nfileOwnerGroupNumber(ownerGroupNumber("%G"),filePath("%p")).\nfileLastModification(lastModification(%T@),filePath("%p")).\nfileInode(inode(%i),filePath("%p")).\nfileSymLink(symLinkObject("%l"),filePath("%p")).\nfilePermissionBits(permissionBits(%m),filePath("%p")).\nfileNumHardLinks(numHardLinks(%n),filePath("%p")).\nfileOwnerUserNumber(ownerUserNumber("%U"),filePath("%p")).\nfileType(type("%y"),filePath("%p")).\n' 

cd $current_dir
