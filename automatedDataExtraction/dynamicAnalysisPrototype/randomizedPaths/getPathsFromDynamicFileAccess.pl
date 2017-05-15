#!/usr/bin/env python

#Note to self: I am assuming that extensions without a class type are generics and labelling them that way in the facts.
#we will need to modify this if I'm wrong about how to handle this type of extension.
#when there is more time, we should look into these by figuring out who issues them and analyzing the issuers with IDA.
#for now, we don't really care though since the only extensions we're worried about are file type and mach type.

import sys
import re

fileAccessPath = sys.argv[1]

# pass the filepath of prolog file access
f = open(fileAccessPath, 'r')
#split each line into a list of results for each process
fileAccessResults = f.read().strip().split("\n")


#step through the results for each process id number
for fileAccessLine in fileAccessResults:
  #extract the PID
  fileAccessPattern = re.compile("fileAccessObservation\(process\(\".*\"\),sourceFile\(\"(.*)\"\),destinationFile\(\"(.*)\"\),operation\(\".*\"\)\)\.")
  fileAccessMatches = re.search(fileAccessPattern,fileAccessLine)
  if fileAccessMatches:
    sourceFile = fileAccessMatches.group(1).strip()
    destinationFile = fileAccessMatches.group(2).strip()
    if sourceFile:
      print sourceFile
    if destinationFile != "No destionation":
      print destinationFile
