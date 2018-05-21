#It may be much simpler to get the mach port name, exported object, exported interface, and entitlements all with the same script.
#all of this initialization code should probably be one or two functions
filePathOniOSDevice=idc.ARGV[1]
outputFile=idc.ARGV[2]
export_dict_file = idc.ARGV[3]
export_dict = pickle.load(open(export_dict_file, "rb"))
with open(idc.ARGV[4], "rb") as f:
  executableDict = pickle.load(f)
f = open(outputFile,'a')
errorMessage = ""
selectorMap = executableDict["selectorMap"]
executableDict[filePathOniOSDevice] = {}
thisExecDict = executableDict[filePathOniOSDevice]

#make a function that generates a list of addresses for a given address
#for address in getSelectorInvocations(...)


thisExecDict["machPortMap"] = {}
machPortMapDict = thisExecDict["machPortMap"]

#These 5 lines occur often enough that I could make them into a function.
#Maybe I could pass the dictionary by reference too.
for address in getSelectorInvocations(selectorMap,"initWithMachServiceName:"):
  mach_service_targetReg = getRegisterNumber("X2")
  minEa = idc.GetFunctionAttr(address, idc.FUNCATTR_START)
  result = getRegisterValueAtAddress(address,minEa,mach_service_targetReg)
  resultString = findStringAssociatedWithAddress(result)

  if resultString != "":	
    #map the mach port name to the address of the objc dispatch call that assigned it.
    machPortMapDict[resultString] = address
  #TODO consult the errorMessage log when we measure the accuracy of this tool.

f.close()
with open(idc.ARGV[4], "wb") as f:
  pickle.dump(executableDict, f)
idc.Exit(0)
