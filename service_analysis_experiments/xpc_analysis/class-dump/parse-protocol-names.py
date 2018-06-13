#!/usr/bin/python

#This script finds xpc protocol names and exposed methods by parsing class-dump output
#It takes two arguments as input:
#   the filepath of the class-dump results to use as input
#   the filepath for a python pickle formatted output

import re
import sys
import pickle

#read arguments
inputFilePath = sys.argv[1]
outputFilePath = sys.argv[2]

#read input file
inputText = open(inputFilePath,'rb').read().strip().replace("\n","").replace("@end","@end\n")
protDict = {}

#find the names of the XPC protocols based on pattern of using NSXPCConnection
for line in inputText.split('\n'):
  protocolPattern = re.compile('\@interface\ (.*?)\ \:\ NSObject \<(.*?)\>\{.*NSXPCConnection.*\;.*?\}')
  protocolMatch = re.match(protocolPattern, line)
  if protocolMatch != None:
    protDict[protocolMatch.group(2)] = []

#find the methods and their arguments for each XPC protocol.
for protName in protDict:
  for line in inputText.split('\n'):
    protocolPattern = re.compile('\@protocol\ '+protName+'(.*)\@end')
    protocolMatch = re.match(protocolPattern, line)
    #if an XPC protocol header is detected, parse out the methods and arguments
    if protocolMatch != None:
      coarseMatch = protocolMatch.group(1).replace(";",";\n")
      #results are stored in a dictionary and written to a pickle file
      protDict[protName] = coarseMatch.split("\n")[:-1]
      #for method in protDict[protName]:
      #  print '"'+method+'"'

print protDict

#output to pickle
with open(outputFilePath, "wb") as f:
  pickle.dump(protDict, f)
