#this script tries to determine the string pointed to by the X0 register when the sandbox_init function is called.
#this should tell us which sandbox profile a process will apply to itself.
import idaapi, idc, idautils,os

full_path = os.path.realpath(__file__)
directory = os.path.dirname(full_path)
f = open(directory+"/output/sandboxInitCalls.csv",'a')
errorMessage = ""
#The header of the output file is functionName,callAddress

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

######################################################
#bottom of getValue function
######################################################

for nName in idautils.Names():
  #f.write(nName[1]+"\n")
  name = nName[1]
  if "_sandbox_init" == name:
    #f.write(nName[1]+","+"%x" % nName[0] + "\n")
    nameAddress = nName[0]
    #now that we have the address of the name we can look for a cross reference.
    for xref in idautils.XrefsTo(nameAddress, 0):
      #f.write("%x" % xref.frm + "\n")
      #this is a stupid loop. I need to find a function header or something to act as a minimum address
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
      #I'm not sure why but register X0 seems to be represented by the int 129
      #the 32 bit one should be R0 = 0, but for 64 bit it is X0 = 129
      info = idaapi.get_inf_structure()

      if info.is_64bit():
	targetReg = 129
      else: 
	targetReg = 0 
      #the getValue function should return a sandbox profile or a helpful error message.
      global errorMessage 
      errorMessage = ""
      profileAddress = getValue(ea,minEa,targetReg)
      f.write(idc.ARGV[1]+","+idc.ARGV[2]+",")
      if errorMessage != "":
	f.write(errorMessage+"\n")
      else:	
	profileString = idc.GetString(profileAddress)
	f.write(profileString+"\n")

f.close()

idc.Exit(0)
