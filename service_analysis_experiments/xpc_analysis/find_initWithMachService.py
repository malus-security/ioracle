targetReg = getRegisterNumber("X1")
errorMessage = ""
#run this in a for loop and scan every objc_msgSend
#also parse the result such that an actual string is output.

functionName = "_objc_msgSend"
for nName in idautils.Names():
  name = nName[1]
  if functionName == name:
    nameAddress = nName[0]
    #now that we have the address of the name we can look for a cross reference.
    for xref in idautils.XrefsTo(nameAddress, 0):
      ea = xref.frm
      minEa = idc.GetFunctionAttr(ea, idc.FUNCATTR_START)
      selectorAddress = getRegisterValueAtAddress(ea,minEa,targetReg)

      if findStringAssociatedWithAddress(selectorAddress) == "initWithMachServiceName:":
	#there is an annoying L that appears at the end of the hex value.
	#the [:-1] code just removes that L by dropping the last character.
	print "Found target at: " + str(hex(ea))[:-1]

	#TODO replace this with a smarter register mapping for 32 and 64 bit.
	mach_service_targetReg = getRegisterNumber("X2")

	result = getRegisterValueAtAddress(ea,minEa,mach_service_targetReg)
	resultString = findStringAssociatedWithAddress(result)
	print resultString
