#!/bin/bash

#remove facts for selfApplied profiles because in the first pass we did not know which profiles were used.
sed '/mechanism(selfApplied)/d' $1 > temp1
#translate the output from strider.py into facts amenable to the other profile usage facts
./runProlog.sh parseSelfAppliedProfiles > temp2
#remove duplicates
sort temp2 | uniq > temp3
#merge nonself and self facts together and output them to specified file
cat temp1 temp3 > $2
