#!/usr/bin/env python

#Note to self: I am assuming that extensions without a class type are generics and labelling them that way in the facts.
#we will need to modify this if I'm wrong about how to handle this type of extension.
#when there is more time, we should look into these by figuring out who issues them and analyzing the issuers with IDA.
#for now, we don't really care though since the only extensions we're worried about are file type and mach type.

import sys
import re

fileAccessPath = sys.argv[1]
processesInfoPath = sys.argv[2]

def getProcessNameFromPid(pid):
  f = open(processesInfoPath, 'r')
  #split each line into a list of results for file access
  fileAccessResults = f.read().strip().split("\n")

  #step through the results for each file access
  for fileAccessLine in fileAccessResults:
    process_info = fileAccessLine.split()
    if fileAccessLine.split()[0] == pid:
      return fileAccessLine.split()[3]
  return "Path Not Found"

# you have to tell this script where the raw file access data is
# pass that filepath as the first argument when launching this script
# pass the pid_uid_gid_comm info as the second

f = open(fileAccessPath, 'r')
#split each line into a list of results for each process
fileAccessResults = f.read().strip().split("\n")
fileAccessResults = fileAccessResults[:-1]

#step through the results for each process id number
for fileAccessLine in fileAccessResults:
  #extract the PID
  fileAccessPattern = re.compile("(\d+)\ ((\w(\ )?)+)?\t((\w*\ )+)(\ +)(([\)\(/\ \.\-]*(\w)+)+)((\t([\(\)/\ \.]*(\w)+)+)?)")
  fileAccessMatches = re.search(fileAccessPattern,fileAccessLine)
  if fileAccessMatches:
    processId = fileAccessMatches.group(1).strip()
    # May miss: processName = fileAccessMatches.group(2)
    processPath = getProcessNameFromPid(processId).strip()
    operation = fileAccessMatches.group(5).strip()
    sourceFile = fileAccessMatches.group(8).strip()
    destinationFile = fileAccessMatches.group(11).strip()
    if not destinationFile:
      destinationFile = "No destionation"
    else:
      destinationFile = destinationFile.strip()
    if operation:
      operation = operation.strip()
    if sourceFile:
      sourceFile = sourceFile.strip()

    sys.stdout.write('fileAccessObservation(')
    sys.stdout.write('process("' + processPath + '"),')
    sys.stdout.write('sourceFile("' + sourceFile + '"),')
    sys.stdout.write('destinationFile("' + destinationFile + '"),')
    sys.stdout.write('operation("' + operation + '")).\n')
