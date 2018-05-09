###########################################################################################
#It's arguable whether this is really a library or not.
#IDA seems to have issues with importing python modules.
#The only way I can make this code easier to share across interfaces is by using cat...
#Seriously, the way to import these functions to an IDA script is as follows:
#cat Malus_IDA_Script_Library.py interfaceUsingTheLibrary.py > idaScriptToInvoke.py
###########################################################################################

import idaapi
import idc
import idautils
import os

###########################################################################################
#BEGIN DEFINITION OF getRegisterNumber
#Given some register as a string (e.g., "R0, "X2"),
#return the integer IDA uses to represent that register.
#This will make our scripts more architecture agnostic since the 64 bit
#register to integer mapping is not intuitive (i.e., X0 maps to 129)
#NOTE for this function R or X could be used interchangably since
#the return result depends on the binary's architecture anyway.
#However, we would have trouble if we track anything other than R or X registers.
###########################################################################################

def getRegisterNumber(regString):
  regex = r"([A-Z])([0-9]+)"
  info = idaapi.get_inf_structure()
  if info.is_64bit():
    return int(re.search(regex,regString).group(2)) + 129
  else:
    return int(re.search(regex,regString).group(2))



###########################################################################################
#BEGIN DEFINITION OF findStringAssociatedWithAddress
#Given some address that directly or indirectly represents a string value,
#find and return that string value.
#For example, the address might point directly to a string, or it could point to a class
#that contains the string as one of it's member values.
###########################################################################################

def findStringAssociatedWithAddress(ea):
  global errorMessage
  #check to see if the address points directly to a C type null terminated string
  if get_str_type(ea) == STRTYPE_TERMCHR:
    return idc.GetString(ea)
  #Otherwise, consider various Class types.
  #selRef_
  elif get_name(ea, 0).startswith('selRef_'):
    return idc.GetString(Qword(ea))
  #___CFConstantStringClassReference
  elif get_name(Qword(ea), 0) == "___CFConstantStringClassReference":
    offset = 0x10
    return idc.GetString(Qword(ea+offset))
  else:
    errorMessage+="ERROR: unrecognized data type when searching for string value"
    return ""
    

###########################################################################################
#BEGIN DEFINITION OF predictReturnValueKnownMethod
#we assume the target register is X0 or R0
#this function will detect known methods and attempt to predict their return values
#this function relies heavily on getRegisterValueAtAddress
###########################################################################################
def predictReturnValueKnownMethod(ea):
  global errorMessage
  targetReg = getRegisterNumber("X1")
  minEa = idc.GetFunctionAttr(ea, idc.FUNCATTR_START)
  result = getRegisterValueAtAddress(ea,minEa,targetReg)
  if findStringAssociatedWithAddress(result) == "stringWithUTF8String:":
    targetReg = getRegisterNumber("X2")
    minEa = idc.GetFunctionAttr(ea, idc.FUNCATTR_START)
    return getRegisterValueAtAddress(ea,minEa,targetReg)
  else:
    errorMessage+="ERROR: could not predict return value because this method has not been modeled"
    return 0



###########################################################################################
#BEGIN DEFINITION OF getRegisterValueAtAddress
#this function will return the value of a given register at a given address
#it does this via backtracing
#if it backtraces to the address set by minEa, it will give up and return an error
###########################################################################################
def getRegisterValueAtAddress(ea,minEa,targetReg):
  #print "analyzing: " + str(hex(ea))[:-1]  
  #print "target is : " + str(targetReg)  
  global errorMessage
  #f.write("%x" % ea + "\n")
  #f.write("%x" % minEa + "\n")
  #f.write(str(targetReg) + "\n")

  #give up if you hit the top of the function
  if ea <= minEa:
    errorMessage+="ERROR: Hit top of function or hit top of basic block with multiple parents"
    return 0

  count_far_code_references = len(list(idautils.XrefsTo(ea, 1)))
  if count_far_code_references > 0:
    #if this gets reached, then we seem to be at the top of a basic block with multiple parents.
    #for now, we can't figure out which parent to follow, so we evaluate the current instruction, and if that doesn't allow us to finish, then we act like we hit top of function.
    minEa = ea

  #If a function is called, the ARM calling convention allows the called function to clobber the X0 or R0 register as a return value.
  #Therefore, if our target register is value 0 (i.e., R0 or X0), we cannot ignore function calls.
  #the targetReg value of 129 seems to be a fluke of 64 bit ARM. I think the value would need to change if we analyze 32 bit as well.
  #TODO make a generic function that helps avoid register value confusion between 32 bit and 64 bit architectures.
  if idc.GetMnem(ea) in ['BL'] and targetReg == getRegisterNumber("X0"):
    #print "found function call while tracking X0: " + str(hex(ea))[:-1]  
    ea = idc.PrevHead(ea)
    return predictReturnValueKnownMethod(ea)


  if idc.GetMnem(ea) in ['ADR','ADRP']:
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


  #load register with address in another register and an immediate offset
  if idc.GetMnem(ea) in ['LDR']:
    i = DecodeInstruction(ea)
    srcOpType = i.Op2.n
    srcOpValue = i.Op2.reg
    
    dest_op = 0
    #src op not relevant for displ type
    offset_op = 1

    destOpType = idc.GetOpType(ea, dest_op)
    destOpValue = idc.GetOperandValue(ea, dest_op)
    offsetOpType = idc.GetOpType(ea, offset_op)
    offsetOpValue = idc.GetOperandValue(ea, offset_op)

    """
    print "destOpType: " + str(destOpType)
    print "destOpValue: " + str(destOpValue)
    print "srcOpType: " + str(srcOpType)
    print "srcOpValue: " + str(srcOpValue)
    print "offsetOpType: " + str(offsetOpType)
    print "offsetOpValue: " + str(offsetOpValue)
    """

    if destOpType == idc.o_reg and destOpValue == targetReg and srcOpType == idc.o_reg and offsetOpType == idc.o_displ:
      targetReg = srcOpValue
      ea = idc.PrevHead(ea)
      return offsetOpValue + getRegisterValueAtAddress(ea,minEa,targetReg)
    

  #TODO deal with adding PC or some other number to the address
  #should be easy with recursion. Just get return the sum of recursively tracking both addends.
  if idc.GetMnem(ea) in ['ADD']:
    dest_op = 0
    src_op = 1
    imm_op = 2
    srcOpType = idc.GetOpType(ea, src_op)
    srcOpValue = idc.GetOperandValue(ea, src_op)
    destOpType = idc.GetOpType(ea, dest_op)
    destOpValue = idc.GetOperandValue(ea, dest_op)
    immOpType = idc.GetOpType(ea, imm_op)
    immOpValue = idc.GetOperandValue(ea, imm_op)

    #TODO This assumes the source register is PC in a 32 bit architecture
    if destOpType == idc.o_reg and destOpValue == targetReg and srcOpType == idc.o_reg and srcOpValue == 15:
      pcValue = ea + 4
      #f.write("%x" % pcValue + "\n")
      ea = idc.PrevHead(ea)
      return pcValue + getRegisterValueAtAddress(ea,minEa,targetReg)
    if destOpType == idc.o_reg and destOpValue == targetReg and srcOpType == idc.o_reg and immOpType == idc.o_imm:
      ea = idc.PrevHead(ea)
      targetReg = srcOpValue
      return getRegisterValueAtAddress(ea,minEa,targetReg) + immOpValue
      

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
	return getRegisterValueAtAddress(ea,minEa, targetReg)    
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
	bottomHalf = getRegisterValueAtAddress(ea,minEa,targetReg)
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
  return getRegisterValueAtAddress(ea,minEa, targetReg)    

