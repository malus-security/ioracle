#!/usr/bin/env python
import sys

inputPath = sys.argv[1]
f = open(inputPath, 'r')
fileResults = f.read().strip().split("\n/")

for l in fileResults:
  lines = l.split('\n')
  object = lines[0]
  #if the object doesn't begin with a / then add one in
  if object[0] != "/":
    object = "/" + object
  aclLines = lines[1:]
  count = 0
  for a in aclLines:
    colonSplit = a.split(':')
    subjectType = colonSplit[0]
    spaceSplit = colonSplit[1].split(' ')
    subject = spaceSplit[0]

    inheritance = ""
    decision = ""
    operations = ""
    
    if len(spaceSplit) == 3:
      inheritance = "notInherited"
      decision = spaceSplit[1]
      operations = spaceSplit[2]
    elif len(spaceSplit) == 4:
      inheritance = spaceSplit[1]
      decision = spaceSplit[2]
      operations = spaceSplit[3]
    else:
      print "ERROR: unexpected list size:"
      print spaceSplit
      
    #print 'fileACL(filePath('+filePath+'),',
    print 'fileACL(',
    print 'ruleNumber(' + str(count) + "),",
    print 'object("' + object + '"),',
    print 'subjectType(' + subjectType + "),",
    print 'subject(' + subject + '),',
    print 'inheritance(' + inheritance +"),",
    print 'decision(' + decision + "),",

    print 'operations([',
    ops = operations.split(',')
    for i in range(len(ops)):
      if i < (len(ops)-1):
	print '"' + ops[i] + '",',
      else:
	print '"' + ops[i] + '"',
    print '])).'

    count = count + 1

