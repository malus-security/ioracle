#!/usr/bin/env python

#TODO I am assuming that extensions without a class type are generics and labelling them that way in the facts.
#we will need to modify this if I'm wrong about how to handle this type of extension.
#when there is more time, we should look into these by figuring out who issues them and analyzing the issuers with IDA.
#for now, we don't really care though since the only extensions we're worried about are for files and mach services.

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
  #print "processID: "+process_id
  for extension_class in extensions_list:
    if "class" in  extension_class:
      #print extension_class
      class_pattern = re.compile("^.*?class\:\ ([^)]+)\)\ {(.*)}.*$")
      class_matches = re.match(class_pattern,extension_class)
      #extract the class name
      class_string = class_matches.group(1)
      #cut out anything before values
      class_values_string = class_matches.group(2)
      #print "class_string: "+class_string
      #print "class_values_string: "+class_values_string

      #split the values within each class
      class_values_list = class_values_string.split("flags=")

      for class_value in class_values_list:
	if ":" in class_value:
	  #print "class_value: "+class_value
	  value_pattern = re.compile("^.*?([^\ ]+):\ (.*?)[;\ ]")
	  value_matches = re.match(value_pattern,class_value)
	  #extract the value type and value string for each value (should be ok to ignore other fields for now).
	  type_string = value_matches.group(1)
	  value_string = value_matches.group(2)
	  #print "type_string: "+type_string
	  #print "value_string: "+value_string

	  print 'sandbox_extension(',
	  #TODO the query is expecting the file path of the process, not the process id number.
	  #this is going to be tricky, but it's a problem we need to solve...
	  #we should be able to output a separate file that maps pid numbers to process file paths.
	  #then we can use logic in this script to match them up before outputting these facts.
	  #if we assume the pids will not wrap around, then our lived become much easier.
	  #we can output a warning if a wrap around happens, but I don't expect it to be an issue during our tests.
	  #It should only be an issue if we try to harvest logs across a reboot.
	  print 'process_id_number("' + str(process_id) + '"),',
	  print 'extension(',
	  print 'class("' + class_string+ '"),',
	  print 'type("' + type_string + '"),',
	  print 'value("' + value_string +'"))).'

	else:
	  print 'sandbox_extension(',
	  print 'process_id_number("' + str(process_id) + '"),',
	  print 'extension(',
	  print 'class("' + class_string+ '"),',
	  print 'type("generic"),',
	  print 'value(""))).'


