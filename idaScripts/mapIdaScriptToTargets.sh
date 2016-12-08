#!/bin/bash

#TODO change this so that it is not hardcoded
rm ./output/sandboxInitCalls.csv

for line in `cat $1`
do 
  name=`echo $line | sed 's/,.*//g'`
  path=`echo $line | sed 's/.*,//g'`
  #second argument will be the idaScript to run
  #third argument will be the directory where the programs to analyze are stored
  #echo $name
  #echo $path
  #echo "calling IDA now"
  #echo "idal64 -S\"$2 $path\" $3$name.i64"
  idal64 -S"$2 $name $path" $3$name.i64
done
