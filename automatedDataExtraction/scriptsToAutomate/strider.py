#strider is a backtracing IDA script we can use to determine the value of a given register when a given function is called.
#this is useful for determining which sandbox profile a process is giving itself or which entitlement key a server is asking about.
#strider may need to be augmented over time to be a smarter iOS backtracer, but it can already handle relatively simple scenarios.
#sometimes the value of the target register might not point directly to the data you want.
#it might point to a struct or another pointer, which will require some post processing.
#USAGE: this script takes three arguments, which are stored in the idc.ARGV list
#This is an example of how I would call this ida script from the command line
#idal64 -S"strider.py 6dbba47caaf844632d97027ab8a5f569 /Developer/usr/libexec/neagent ./output/striderOutput.csv" ./programsToAnalyze/6dbba47caaf844632d97027ab8a5f569.i64

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
#BEGIN DEFINITION OF getValue
#this function will return the value of a given register at a given address
#it does this via backtracing
#if it backtraces to the address set by minEa, it will give up and return an error
###########################################################################################
def getValue(ea,minEa,targetReg):
  global errorMessage
  #f.write("%x" % ea + "\n")
  #f.write("%x" % minEa + "\n")
  #f.write(str(targetReg) + "\n")

  #give up if you hit the top of the function
  if ea <= minEa:
    errorMessage+="ERROR: Hit top of function"
    return 0

  if idc.GetMnem(ea) in ['ADR']:
    dest_op = 0
    src_op = 1
    srcOpType = idc.GetOpType(ea, src_op)
    srcOpValue = idc.GetOperandValue(ea, src_op)
    destOpType = idc.GetOpType(ea, dest_op)
    destOpValue = idc.GetOperandValue(ea, dest_op)
    #f.write(str(destOpValue)+"\n")
    if destOpType == idc.o_reg and destOpValue == targetReg and srcOpType == idc.o_imm:
      #found goal, so return it as a string
      return srcOpValue


  #TODO deal with adding PC or some other number to the address
  #should be easy with recursion. Just get return the sum of recursively tracking both addends.
  if idc.GetMnem(ea) in ['ADD']:
    dest_op = 0
    src_op = 1
    srcOpType = idc.GetOpType(ea, src_op)
    srcOpValue = idc.GetOperandValue(ea, src_op)
    destOpType = idc.GetOpType(ea, dest_op)
    destOpValue = idc.GetOperandValue(ea, dest_op)
    #I'm assuming the source is the PC register with a 32 bit executable
    if destOpType == idc.o_reg and destOpValue == targetReg and srcOpType == idc.o_reg and srcOpValue == 15:
      pcValue = ea + 4
      #f.write("%x" % pcValue + "\n")
      ea = idc.PrevHead(ea)
      return pcValue + getValue(ea,minEa,targetReg)

  #TODO include how to handle this if the src is an address that probably points to a string
  if idc.GetMnem(ea) in ['MOV']:
    dest_op = 0
    src_op = 1
    srcOpType = idc.GetOpType(ea, src_op)
    srcOpValue = idc.GetOperandValue(ea, src_op)
    destOpType = idc.GetOpType(ea, dest_op)
    destOpValue = idc.GetOperandValue(ea, dest_op)
    if destOpType == idc.o_reg and destOpValue == targetReg: 
      if srcOpType == idc.o_reg:
	#start tracking a new register.
	targetReg = srcOpValue
	ea = idc.PrevHead(ea)
	return getValue(ea,minEa, targetReg)    
      if srcOpType == idc.o_imm:
	#this should be the address we are looking for, so return it
	return srcOpValue

  if idc.GetMnem(ea) in ['MOVT']:
    src_op = 1
    dest_op = 0
    srcOpType = idc.GetOpType(ea, src_op)
    srcOpValue = idc.GetOperandValue(ea, src_op)
    destOpType = idc.GetOpType(ea, dest_op)
    destOpValue = idc.GetOperandValue(ea, dest_op)
    #Are we writing to a register and is that register the one we are tracking?
    if destOpType == idc.o_reg and destOpValue == targetReg:
      if srcOpType == idc.o_imm:
	#this represents the top half of the value we want
	#but we need to track the register farther to know what the bottom half is
	ea = idc.PrevHead(ea)
	bottomHalf = getValue(ea,minEa,targetReg)
	#I should have a sanity check here to know when something has gone wrong.
	#I should refine my error messages to also include addresses, see dispatchExtractor for examples
	if errorMessage != "":
	  errorMessage += "ERROR: Failed to get value in MOVT."
	  return 0
	else:
	  #I hope that I'm correctly overwriting the first 16 bits with the src of MOVT
	  topHalf = srcOpValue << 16
	  botHalf = bottomHalf & 0x0000ffff
	  afterMOVT = topHalf ^ botHalf
	  return afterMOVT
      else:
	errorMessage += "ERROR: cannot handle this type of MOVT."
	return 0
    #This instruction has no impact on the register we are tracking. Skip it.
  #end of code for MOVT

  #keep backtracking and move on to previous instruction
  ea = idc.PrevHead(ea)
  return getValue(ea,minEa, targetReg)    

###########################################################################################
#END DEFINITION OF getValue
###########################################################################################

###########################################################################################
#BEGIN: Set up variables based on config file
###########################################################################################

def getConfigValue(lineNumber):
  regex = r"(^.*=)(.*$)"
  return re.search(regex,configList[lineNumber]).group(2)

configList = open(configFile,'r').read().strip().split("\n")

register32bit=getConfigValue(1)
register64bit=getConfigValue(2)
functionName=getConfigValue(3)
resultIsClass=getConfigValue(4)
classOffset=getConfigValue(5)

resultIsClass=int(resultIsClass)
classOffset=int(classOffset,16)

#determine target register number based on architecture

#TODO make a smarter mapping of register names to numbers
#for now we can only handle R and X registers as targets
regex = r"([A-Z])([0-9]+)"
info = idaapi.get_inf_structure()
targetReg=-1
if info.is_64bit():
  targetReg = int(re.search(regex,register64bit).group(2)) + 129
else:
  targetReg = int(re.search(regex,register32bit).group(2))

f = open(outputFile,'a')
errorMessage = ""
count = 0

###########################################################################################
#END: Set up variables based on config file
###########################################################################################

for nName in idautils.Names():
  #f.write(nName[1]+"\n")
  name = nName[1]
  #if "_sandbox_init" == name or "_sandbox_apply_container" == name:
  if functionName == name:
    count = count + 1
    #f.write(nName[1]+","+"%x" % nName[0] + "\n")
    nameAddress = nName[0]
    #now that we have the address of the name we can look for a cross reference.
    for xref in idautils.XrefsTo(nameAddress, 0):
      #f.write("%x" % xref.frm + "\n")
      ea = xref.frm
      #try to set the minimum instruction to consider as the top of the current function.
      minEa = idc.GetFunctionAttr(ea, idc.FUNCATTR_START)
      #if minEa seems to be something ridiculous like a value larger than ea, then just define a dumb, constant backtracing limit.
      #TODO this does make a lot of assumptions, but it should be ok for now.
      if ea <= minEa:
	#my arbitrary limit is 50 instruction 
	sizeOfInst = 4
	numInstToTry = 50
	minEa = ea - (sizeOfInst * numInstToTry)

      #the getValue function should return a sandbox profile or a helpful error message.
      global errorMessage 
      errorMessage = ""
      resultAddress = getValue(ea,minEa,targetReg)
      #f.write(name+","+idc.ARGV[1]+","+idc.ARGV[2]+",")
      resultString=None
      #If there are errors, then don't worry about the result and just output the errors
      if errorMessage != "":
	#f.write(name+","+idc.ARGV[1]+","+idc.ARGV[2]+",")
	#f.write(errorMessage+"\n")
	continue

      if resultIsClass:
	#the function we're tracking may take a class as its input instead of a raw string.
	#therefore, we need to find the string we want within the class.
	#this can be done by using the correct offset from the beginning of the class and dereferencing.
	classAddress = resultAddress
	#I think we use Qword for 64 bit executables
	#This will return the content of the address passed as a paramter
	#I chose Qword since I think this is how an address value is represented.
	#I think this is like dereferencing a pointer.
	stringAddress= Qword(classAddress + classOffset)
	resultString = idc.GetString(stringAddress)
      else:
	resultString = idc.GetString(resultAddress)

      if resultString == None:
	#I guess just putting () here will do nothing, but without it, IDA freaks out about the else statement below.
	()
	#f.write(name+","+idc.ARGV[1]+","+idc.ARGV[2]+",")
	#f.write("ERROR: %x result string equalled None\n" % stringAddress)
      else:
	#f.write(name+","+idc.ARGV[1]+","+idc.ARGV[2]+",")
	#f.write(resultString+"\n")
	f.write("functionCalled(filePath(\""+filePathOniOSDevice+"\"),function(\""+name+"\"),parameter(\""+resultString.replace('"',"'")+"\")).\n")
	  

#if count == 0:
  #f.write("ERROR: no name,"+idc.ARGV[1]+","+idc.ARGV[2]+",ERROR: did not find any relevant names.\n")

f.close()

idc.Exit(0)
