#!/bin/bash

make
codesign -s alecdeshotels $1.executable
scp -P 2222 $1.executable root@localhost:/var/mobile/sandbox_extension_tests/
