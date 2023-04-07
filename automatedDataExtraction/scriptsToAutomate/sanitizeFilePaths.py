#!/usr/bin/python3

import re
import sys

#open with rb so file is treated as binary and the content treated as bytes (utf8 failure)
fdata = open(sys.argv[1],"rb").read().strip()
facts = fdata.split(b"\n")

for line in facts:
  #print line
  #pattern = re.compile(',filepath\(\"(.*)\"\)\)\.')
  pattern = re.compile(b'(^.*,filePath\(\")(.*)(\"\)\)\.$)')
  #pattern = re.compile('^.*,filepath\(.*')
  match = pattern.match(line)
  filePath = match.group(2)
  #print filePath
  sanitizedPath = filePath.replace(b'"',bytes('_DOUBLEQUOTEWASHERE_', 'utf-8')).replace(b'\\',bytes('_BACKSLASHWASHERE_', 'utf-8'))
  #print sanitizedPath
  sanitizedLine = match.group(1) + sanitizedPath + match.group(3)
  #print sanitizedLine
