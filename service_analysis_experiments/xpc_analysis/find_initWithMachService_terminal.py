#idat64 -S"find_initWithMachService_With_Library.py /some/dir/locationd ./output/initWithMachService.out" ./executables/locationd.i64

#idaapi.autoWait()

filePathOniOSDevice=idc.ARGV[1]
outputFile=idc.ARGV[2]

targetReg = getRegisterNumber("X1")
errorMessage = ""
f = open(outputFile,'a')
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
      minEa = sanitizeMinEa(ea, minEa)
      #We are definitely getting a lot of errors here, but I think we are still finding the selectors we need.


      try:
	selectorAddress = getRegisterValueAtAddress(ea,minEa,targetReg)
      except RuntimeError as runErr:
	if runErr.args[0] != 'maximum recursion depth exceeded':
	  # different type of runtime error
	  raise
	else: 
	  print 'Recursion Explosion: ' + str(hex(ea))



      #f.write(findStringAssociatedWithAddress(selectorAddress) + "\n")

      selString = findStringAssociatedWithAddress(selectorAddress) 
      if selString.startswith("initWithMachServiceName:"):
	errorMessage = ""
	#there is an annoying L that appears at the end of the hex value.
	#the [:-1] code just removes that L by dropping the last character.

	#TODO replace this with a smarter register mapping for 32 and 64 bit.
	mach_service_targetReg = getRegisterNumber("X2")

	result = getRegisterValueAtAddress(ea,minEa,mach_service_targetReg)
	resultString = findStringAssociatedWithAddress(result)
	f.write("initWithMachServiceName(filePath(\""+filePathOniOSDevice+"\"),callAddress(\""+str(hex(ea))[:-1]+"\"),machServiceName(\""+resultString.replace('"',"'")+"\")).\n")
	if errorMessage != "":
	  print errorMessage

f.close()
idc.Exit(0)
