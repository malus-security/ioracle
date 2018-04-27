register64bit = "X1"
regex = r"([A-Z])([0-9]+)"
targetReg = int(re.search(regex,register64bit).group(2)) + 129
errorMessage = ""
count = 0
functionName = "_objc_msgSend"
#run this in a for loop and scan every objc_msgSend
#also parse the result such that an actual string is output.


for nName in idautils.Names():
  name = nName[1]
  if functionName == name:
    count = count + 1

    nameAddress = nName[0]
    #now that we have the address of the name we can look for a cross reference.
    for xref in idautils.XrefsTo(nameAddress, 0):
      ea = xref.frm
      minEa = idc.GetFunctionAttr(ea, idc.FUNCATTR_START)

      result = getRegisterValueAtAddress(ea,minEa,targetReg)
      stringAddress = Qword(result)
      resultString = idc.GetString(stringAddress)
      if resultString == "initWithMachServiceName:":
	#there is an annoying L that appears at the end of the hex value.
	#the [:-1] code just removes that L by dropping the last character.
	print "Found target at: " + str(hex(ea))[:-1]

	#TODO there is a problematic situation for when we search for the mach port names.
	#I've taken a screen shot, but an example can be seen at 0x100DB9D8C of locationd for iOS 10.1
	#the X0 register is filled by another call to objc_msgSend which does some UTF conversion on a string
	#We can solve this problem by adding extra logic to the backtracer to infer the output of known objc methods.
	#For now, we should probably just run analysis at scale without this extra logic and see what we find.


