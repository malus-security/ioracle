#!/bin/bash

inputFile=$1

#kill any double quote not associated with parenthesis.
cat $inputFile | grep -v '\\' | grep -v '[^(]"[^)]'
