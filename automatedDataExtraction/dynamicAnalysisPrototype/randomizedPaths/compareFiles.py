#!/bin/python
import sys

firstFile = sys.argv[1]
secondFile = sys.argv[2]

f = open(firstFile, 'r')


filesFirst = f.read().strip().split("\n")

for filesFirstLine in filesFirst:
  with open(secondFile, 'r') as filesSecond:
    for filesSecondLine in filesSecond:
      if filesFirstLine.strip() == filesSecondLine.strip():
        print filesFirstLine
