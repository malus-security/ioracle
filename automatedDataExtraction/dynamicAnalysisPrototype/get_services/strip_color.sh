#!/bin/bash
#requires gsed to be installed

cat $1 | gsed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g"
