#!/bin/bash

if test $# -ne 2; then
	echo "Usage: $0 userOniOSDevice hostOfiOSdevice" 1>&2
	echo "Example: $0 root localhost" 1>&2
	exit 1
fi

user="$1"
host="$2"

cat ~/.ssh/id_rsa.pub | ssh $user@$host 'cat >> .ssh/authorized_keys'
