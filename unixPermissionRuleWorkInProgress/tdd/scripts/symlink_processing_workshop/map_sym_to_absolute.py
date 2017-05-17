#!/usr/bin/python

import re
import sys

"""
def resolve_links(path,symlink_target_dictionary):
  if path == "/":
    return "/"
  elif "/" not in path:
    parent = "ERROR: invalidFilePath"
  else:
    dictionary_match = symlink_target_dictionary.get(path)
    if dictionary_match == None:
      resolved = path
    else
      resolved 
    pattern = re.compile('(^.*)\/(.*)$')
    match = pattern.match(path)
    parent = match.group(1)
    child = match.group(2)
    if parent == "":
      parent = "/"
    else:
      #recursively get the parent of the parent if there is a parent
      return (resolve_links(parent, symlink_target_dictionary) + "/" + child)
"""

def resolve_links(path,symlink_target_dictionary):
  for link in symlink_target_dictionary.keys():
    if path.startswith(link):
      print "link "+link
      print "target "+ symlink_target_dictionary[link]
      path = symlink_target_dictionary[link] + path[len(link):]
  return path
    


#get the file paths
fdata = open(sys.argv[1],"r").read().strip()
filePaths = fdata.split("\n")

#get the symlinks
symdata = open(sys.argv[2],"r").read().strip()
symlink_lines = symdata.split("\n")

#start a dictionary
symlink_target_dictionary = {}
for symlink in symlink_lines:
  pattern = re.compile('^fileSymLink\(symLinkObject\("([^"]*)"\),filePath\("([^"]*)"\)\)\.$')
  match = pattern.match(symlink)
  link_target = match.group(1)
  link_location = match.group(2)
  symlink_target_dictionary[link_location] = link_target


for path in filePaths:
  #we need to process each parent in the filepath and see if any are symbolic links
  #if none are links then we don't need to do anything.
  #if some are links then we map to absolute path.
  start = path

  dirty_bit = 1
  while dirty_bit == 1:
    result = resolve_links(path,symlink_target_dictionary)
    if result == path:
      dirty_bit = 0
    else:
      print path
      print result
      path = result
  
  #prepend a / in case the private/var symlink target cuts it off
  path = "/" + path
  finish = path.replace("//","/")

  if start != finish:
    print "start  : "+start
    print "finish : "+finish

