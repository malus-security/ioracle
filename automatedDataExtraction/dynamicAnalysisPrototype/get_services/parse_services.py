#!/usr/bin/env python

#This script converts output from procexp about mach_services into Prolog facts about mach_services

import sys
import re

serviceOutputPath= sys.argv[1]
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

#you have to tell this script where the raw mach service data is
#pass that filepath as the first argument when launching this script
f = open(serviceOutputPath, 'r')
#split each line into a list of results for each service
serviceResults = f.read().strip().split("\n")

#step through the results for each service
for serviceLine in serviceResults:
  #print serviceLine
  service_direction = "no_connections"
  if "->" in serviceLine:
    service_direction = "sending"
  if "<-" in serviceLine:
    service_direction = "receiving"
  if "<-" in serviceLine and "->" in serviceLine:
    print "ERROR cannot determine service direction"
      
  #sometimes the service is neither sending nor receiving and will not have an arrow at all.
  service_pattern = re.compile("(^[^:]*):([^:]*):([^\t]*)\t\"([^\"]*)\"\t(.*$)")
  service_matches = re.match(service_pattern,serviceLine)
  scanned_process_nickname = service_matches.group(1)
  scanned_process_pid = service_matches.group(2)
  scanned_process_servicenumber = service_matches.group(3)
  service_name = service_matches.group(4)
  service_connections_string = service_matches.group(5)
  process_executable_path = getProcessNameFromPid(scanned_process_pid)
  #If the returned process path is invalid, skip this line of the file
  if process_executable_path[0] != "/":
    continue

  """
  print scanned_process_nickname
  print scanned_process_pid
  print scanned_process_servicenumber
  print service_name
  print service_connections_string
  print process_executable_path
  """

  #How do we want these Prolog facts to look...
  #I'm assuming we don't need the port numbers, but we should learn more in case they are useful
  # dynamic_service_observation(scanned_proc("/System/mstreamd"),direction("receiving"),service("com.apple.mediastream.sharing"),connections([...]))
  if service_direction == "no_connections":
    print 'dynamic_service_observation(scanned_proc("' + process_executable_path + '"),direction("no_connections"),service("' + service_name + '"),connections([])).'
  else:
    #break down the list of connecting processes
    service_connections_string = service_connections_string.replace(" ","")
    service_connections_string = service_connections_string.replace("\t","")
    #Levin seems to mark certain connections as HSP and adds notes (maybe Highly Sensitive Process?)
    #We need to remove these notes from the output
    connection_pattern = re.compile(".*?(?:<-|->)(.*$)")
    connection_matches = re.match(connection_pattern,service_connections_string)
    trimmed_connection_string = connection_matches.group(1)
    connection_list = re.split('->|<-',trimmed_connection_string)
    connection_procs = []
    for c in connection_list:
      proc_nickname,pid,port_number = c.split(":")
      connection_path = getProcessNameFromPid(pid)
      #skip connections with unidentifiable paths
      if process_executable_path[0] == "/":
        connection_procs.append(connection_path)
    #skip this line if the only connections have unidentifiable paths
    if len(connection_procs) == 0:
      continue
    #print connection_procs
    #It would be easy to add in a value that notes how many connections there are, but I don't think it's necessary unless we have trouble making the same query in Prolog.
    #TODO why had I been using sys.stdout.write instead of print?
    print 'dynamic_service_observation(scanned_proc("' + process_executable_path + '"),direction("' + service_direction + '"),service("' + service_name + '"),connections(' + str(connection_procs) + ')).'

