#!/bin/bash

make
codesign -s ladeshot $1.executable
scp -P 2270 $1.executable root@localhost:/var/mobile/home_test/
