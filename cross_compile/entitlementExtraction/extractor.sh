#!/bin/bash 

for i in $( ls apps/); 
do
  codesign -d --entitlements :- apps/$i | grep "<key>.*</key>" | sed 's/^.*\<key\>//' | sed 's;\</key\>;;' > entitlementsRaw/$i
done
