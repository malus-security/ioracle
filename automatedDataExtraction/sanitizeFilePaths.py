#!/usr/bin/python

import re
import sys

fdata = open(sys.argv[1],"r").read().strip()
facts = fdata.split("\n")

for line in facts:
  #print line
  #pattern = re.compile(',filepath\(\"(.*)\"\)\)\.')
  pattern = re.compile('(^.*,filepath\(\")(.*)(\"\)\)\.$)')
  #pattern = re.compile('^.*,filepath\(.*')
  match = pattern.match(line)
  filePath = match.group(2)
  #print filePath
  sanitizedPath = filePath.replace('"','_DOUBLEQUOTEWASHERE_').replace('\\','_BACKSLASHWASHERE_')
  #print sanitizedPath
  sanitizedLine = match.group(1) + sanitizedPath + match.group(3)
  print sanitizedLine
