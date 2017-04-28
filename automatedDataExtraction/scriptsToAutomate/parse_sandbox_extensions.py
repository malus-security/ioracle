#!/usr/bin/env python
import sys
import re

inputPath = sys.argv[1]
f = open(inputPath, 'r')
processResults = f.read().strip().split("\n")

for processLine in processResults:
  #extract the PID
  #cut out anything before extensions start
  process_pattern = re.compile("^PID\ ([^\ ]+)\ .*?(extensions.*$)")
  process_matches = re.match(process_pattern,processLine)
  process_id = process_matches.group(1)
  extensions_string = process_matches.group(2)
  #split the extension classess apart from each other
  extensions_list = extensions_string.split("extensions ")
  print "processID: "+process_id
  for extension_class in extensions_list:
    if "class" in  extension_class:
      print extension_class
      class_pattern = re.compile("^.*?class\:\ ([^)]+)\)\ {(.*)}.*$")
      class_matches = re.match(class_pattern,extension_class)
      #extract the class name
      class_string = class_matches.group(1)
      #cut out anything before values
      class_values_string = class_matches.group(2)
      print "class_string: "+class_string
      print "class_values_string: "+class_values_string

      #TODO we might have trouble when there are no values for the extension class.
      #We should be able to model these somehow in the prolog facts though.
      #Maybe the values could be in a prolog list, and if there aren't any we just make the list empty
      #sandbox_extension(class(),values[value(value_type(),value_string()),value(value_type(),value_string())]).
      #sandbox_extension(class(),values[]).
  
      #split the values within each class
      class_values_list = class_values_string.split("flags=")

      for class_value in class_values_list:
	if ":" in class_value:
	  print "class_value: "+class_value
	  value_pattern = re.compile("^.*?([^\ ]+):\ (.*?)[;\ ]")
	  value_matches = re.match(value_pattern,class_value)
	  #extract the value type and value string for each value (should be ok to ignore other fields for now).
	  type_string = value_matches.group(1)
	  value_string = value_matches.group(2)
	  print "type_string: "+type_string
	  print "value_string: "+value_string


"""
  processLine = l.split('\n')
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
"""
