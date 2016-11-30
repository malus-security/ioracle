#!/bin/bash

#the find command also has a printf option and provides much of the same data as stat

find / -printf 'file(filepath("%p"),size(%s)).\nfile(filepath("%p"),ownerGroupName("%g")).\nfile(filepath("%p"),lastModification(%T@)).\nfile(filepath("%p"),inode(%i)).\nfile(filepath("%p"),symLinkObject("%l")).\nfile(filepath("%p"),permissionBits(%m)).\nfile(filepath("%p"),numHardLinks(%n)).\nfile(filepath("%p"),ownerUserName("%u")).\nfile(filepath("%p"),type("%y")).\n'

#I may need to remove part of the file path if I am running this extraction on firmware files.
