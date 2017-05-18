#!/usr/bin/python

import re
import sys

if len(sys.argv) < 5:
  print "Usage: ./map_sym_to_absolute.py file_access_observations.pl process_ownership_observations.pl sandbox_extension_observations.pl symlink_metadata_facts.pl"
  exit()

def resolve_links(path,symlink_target_dictionary):
  for link in symlink_target_dictionary.keys():
    if path.startswith(link):
      #print "link "+link
      #print "target "+ symlink_target_dictionary[link]
      path = symlink_target_dictionary[link] + path[len(link):]
  return path

def get_absolute_path(path, symlink_target_dictionary):
  start = path

  dirty_bit = 1
  while dirty_bit == 1:
    result = resolve_links(path,symlink_target_dictionary)
    if result == path:
      dirty_bit = 0
    else:
      #print path
      #print result
      path = result
  
  #prepend a / in case the private/var symlink target cuts it off
  path = "/" + path
  finish = path.replace("//","/")
  return finish

  #if start != finish:
    #print "start  : "+start
    #print "finish : "+finish

#get the file paths
#This needs to use the three prolog files as sources
#fdata = open(sys.argv[1],"r").read().strip()
#filePaths = fdata.split("\n")

fdata = open(sys.argv[1],"r").read().strip()
file_access_entries = fdata.split("\n")

pdata = open(sys.argv[2],"r").read().strip()
process_ownership_entries = pdata.split("\n")

sdata = open(sys.argv[3],"r").read().strip()
sandbox_extension_entries = sdata.split("\n")

#get the symlinks
symdata = open(sys.argv[4],"r").read().strip()
symlink_lines = symdata.split("\n")

#start a dictionary of symlinks
symlink_target_dictionary = {}
for symlink in symlink_lines:
  pattern = re.compile('^fileSymLink\(symLinkObject\("([^"]*)"\),filePath\("([^"]*)"\)\)\.$')
  match = pattern.match(symlink)
  link_target = match.group(1)
  link_location = match.group(2)
  symlink_target_dictionary[link_location] = link_target

for file_access in file_access_entries:
  pattern = re.compile('(^fileAccessObservation\(process\(")([^"]*)(".*)$')
  match = pattern.match(file_access)
  prefix = match.group(1)
  path = match.group(2)
  postfix = match.group(3)
  #some of the process paths are invalid and I'd rather throw them out than leave them in the data set
  if "/" in path:
    absolute_path = get_absolute_path(path, symlink_target_dictionary)
    print prefix + absolute_path + postfix

for process_ownership in process_ownership_entries:
  pattern = re.compile('(^.*,comm\(")([^"]*)(.*$)')
  match = pattern.match(process_ownership)
  prefix = match.group(1)
  path = match.group(2)
  postfix = match.group(3)
  #some of the process paths are invalid and I'd rather throw them out than leave them in the data set
  if "/" in path:
    absolute_path = get_absolute_path(path, symlink_target_dictionary)
    print prefix + absolute_path + postfix

for sandbox_extension in sandbox_extension_entries:
  #we only need to worry about symbolic links in the file path type values
  if ",type(\"file\")," in sandbox_extension:
    pattern = re.compile('(sandbox_extension\(process\(")([^"]*)(".*,type\("file"\),value\(")([^"]*)(.*$)')
    match = pattern.match(sandbox_extension)
    prefix = match.group(1)
    process_path = match.group(2)
    between_process_and_value = match.group(3)
    value_path = match.group(4)
    postfix = match.group(5)
    #some of the process paths are invalid and I'd rather throw them out than leave them in the data set
    if "/" in process_path:
      absolute_process_path = get_absolute_path(process_path, symlink_target_dictionary)
      absolute_value_path = get_absolute_path(value_path, symlink_target_dictionary)
      print prefix + absolute_process_path + between_process_and_value + absolute_value_path + postfix
  else:
    pattern = re.compile('(sandbox_extension\(process\(")([^"]*)(.*$)')
    match = pattern.match(sandbox_extension)
    prefix = match.group(1)
    path = match.group(2)
    postfix = match.group(3)
    #some of the process paths are invalid and I'd rather throw them out than leave them in the data set
    if "/" in path:
      absolute_path = get_absolute_path(path, symlink_target_dictionary)
      print prefix + absolute_path + postfix

