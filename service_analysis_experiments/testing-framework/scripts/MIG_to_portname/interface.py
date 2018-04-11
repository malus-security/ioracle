import idaapi
import idc
import idautils
import os

#USAGE: this script takes three arguments, which are stored in the idc.ARGV list
localNameOfExecutable=idc.ARGV[1]
filePathOniOSDevice=idc.ARGV[2]
outputFile=idc.ARGV[3]
configFile=idc.ARGV[4]

###########################################################################################
#BEGIN: Set up variables based on config file
###########################################################################################

configList = open(configFile,'r').read().strip().split("\n")

f = open(outputFile,'a')
f.write("Ran ida script on "+filePathOniOSDevice+"\n")
#f.write("functionCalled(filePath(\""+filePathOniOSDevice+"\"),function(\""+name+"\"),parameter(\""+resultString.replace('"',"'")+"\")).\n")

f.close()

idc.Exit(0)
