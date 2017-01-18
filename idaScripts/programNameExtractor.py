import idaapi
import idc
import idautils
import os

#USAGE: this script takes three arguments, which are stored in the idc.ARGV list
localNameOfExecutable=idc.ARGV[1]
filePathOniOSDevice=idc.ARGV[2]
outputFile=idc.ARGV[3]
#I should make the config file an optional input, but I'm just ignoring it for now.
configFile=idc.ARGV[4]

f = open(outputFile,'a')

for nName in idautils.Names():
  name = nName[1]
  nameAddress = nName[0]
  f.write("nameFromProgram(filePath(\""+filePathOniOSDevice+"\"),name(\""+name+"\")).\n")
	  

f.close()

idc.Exit(0)
