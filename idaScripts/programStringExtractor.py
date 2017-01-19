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

s = idautils.Strings(False)
s.setup(strtypes=Strings.STR_C)
for i, v in enumerate(s):
  seg=idc.SegName(v.ea)

  #check to determine if the string is ascii
  try:
    str(v).decode('ascii')
  except UnicodeDecodeError:
    #if the string is non-ascii then skip it.
    continue
  else:
    #I'm probably replacing more things than I should, but prolog is getting confused by random backslashes.
    currentString=str(v).replace("\n","").replace('"',"'").replace("\\","")
    f.write("stringFromProgram(filePath(\""+filePathOniOSDevice+"\"),theString(\""+currentString+"\")).\n")

f.close()

idc.Exit(0)
