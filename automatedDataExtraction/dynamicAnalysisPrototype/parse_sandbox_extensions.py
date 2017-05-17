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
  #split each line into a list of results for each process
  processResults = f.read().strip().split("\n")

  #step through the results for each process id number
  for processLine in processResults:
    process_info = processLine.split()
    if processLine.split()[0] == pid:
      return processLine.split()[3]
  return "Path Not Found"

#you have to tell this script where the raw sandbox extension data is
#pass that filepath as the first argument when launching this script
f = open(fileAccessPath, 'r')
#split each line into a list of results for each process
processResults = f.read().strip().split("\n")

#step through the results for each process id number
for processLine in processResults:
  #extract the PID
  #cut out anything before extensions start
  process_pattern = re.compile("^PID\ ([^\ ]+)\ .*?(extensions.*$)")
  process_matches = re.match(process_pattern,processLine)
  process_id = process_matches.group(1)
  process_path = getProcessNameFromPid(process_id)
  extensions_string = process_matches.group(2)
  #split the extension classess apart from each other
  extensions_list = extensions_string.split("extensions ")
  for extension_class in extensions_list:
    if "class" in  extension_class:
      class_pattern = re.compile("^.*?class\:\ ([^)]+)\)\ {(.*)}.*$")
      class_matches = re.match(class_pattern,extension_class)
      #extract the class name
      class_string = class_matches.group(1)
      #cut out anything before values
      class_values_string = class_matches.group(2)

      #split the values within each class
      class_values_list = class_values_string.split("flags=")
      if class_values_list[0] == ' ':
        sys.stdout.write('sandbox_extension(')
        sys.stdout.write('process("' + process_path + '"),')
        sys.stdout.write('extension(')
        sys.stdout.write('class("' + class_string+ '"),')
        sys.stdout.write('type("generic"),')
        sys.stdout.write('value(""))).\n')
        continue


      for class_value in class_values_list:
	if ":" in class_value:
	  value_pattern = re.compile("^.*?([^\ ]+):\ (.*?)[;\ ]")
	  value_matches = re.match(value_pattern,class_value)
	  #extract the value type and value string for each value (should be ok to ignore other fields for now).
	  type_string = value_matches.group(1)
	  value_string = value_matches.group(2)

	  #output in Prolog fact format
	  sys.stdout.write('sandbox_extension(')
	  #TODO the query is expecting the file path of the process, not the process id number.
	  #this is going to be tricky, but it's a problem we need to solve...
	  #we should be able to output a separate file that maps pid numbers to process file paths.
	  #then we can use logic in this script to match them up before outputting these facts.
	  #if we assume the pids will not wrap around, then our lives become much easier.
	  #we can output a warning if a wrap around happens, but I don't expect it to be an issue during our tests.
	  #It should only be an issue if we try to harvest logs across a reboot.
	  sys.stdout.write('process("' + process_path + '"),')
	  sys.stdout.write('extension(')
	  sys.stdout.write('class("' + class_string + '"),')
	  sys.stdout.write('type("' + type_string + '"),')
	  sys.stdout.write('value("' + value_string +'"))).\n')
