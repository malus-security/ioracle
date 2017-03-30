#!/usr/bin/python

import re
import sys

fdata = open(sys.argv[1],"r").read().strip()
filePaths = fdata.split("\n")

for child in filePaths:
  if child == "/":
    parent = "rootDirectoryHasNoParent"
  else:
    pattern = re.compile('(^.*)\/')
    match = pattern.match(child)
    parent = match.group(1)
    if parent == "":
      parent = "/"
  print "dirParent(parent(\""+parent+"\"),child(\""+child+"\"))."
