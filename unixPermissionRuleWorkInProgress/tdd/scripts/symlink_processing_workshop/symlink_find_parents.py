#!/usr/bin/python

import re
import sys

def get_parent(path):
  if path == "/":
    parent = "rootDirectoryHasNoParent"
  elif "/" not in path:
    parent = "ERROR: invalidFilePath"
  else:
    pattern = re.compile('(^.*)\/')
    match = pattern.match(path)
    parent = match.group(1)
    if parent == "":
      parent = "/"
    else:
      #recursively get the parent of the parent if there is a parent
      get_parent(parent)
  print "dynamic_parent(parent(\""+parent+"\"),child(\""+path+"\"))."

    

fdata = open(sys.argv[1],"r").read().strip()
filePaths = fdata.split("\n")

for path in filePaths:
  get_parent(path)

