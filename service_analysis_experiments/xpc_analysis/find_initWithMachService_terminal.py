#It may be much simpler to get the mach port name, exported object, exported interface, and entitlements all with the same script.
#all of this initialization code should probably be one or two functions
filepathoniosdevice=idc.ARGV[1]
outputFile=idc.ARGV[2]
export_dict_file = idc.ARGV[3]
export_dict = pickle.load(open(export_dict_file, "rb"))
with open(idc.ARGV[4], "rb") as f:
  executableDict = pickle.load(f)
f = open(outputFile,'a')
errorMessage = ""
selectorMap = executableDict["selectorMap"]
executableDict["filePath"] = filepathoniosdevice

idaapi.load_and_run_plugin("objc", 1)

#make a function that generates a list of addresses for a given address
#for address in getSelectorInvocations(...)


#######################################################################
#Get Mach Port Mapping
#######################################################################
executableDict["machPortMap"] = {}
machPortMapDict = executableDict["machPortMap"]
#These 5 lines occur often enough that I could make them into a function.
#Maybe I could pass the dictionary by reference too.
for address in getSelectorInvocations(selectorMap,"initWithMachServiceName:"):
  mach_service_targetReg = getRegisterNumber("X2")
  minEa = idc.GetFunctionAttr(address, idc.FUNCATTR_START)
  result = getRegisterValueAtAddress(address,minEa,mach_service_targetReg)
  resultString = findStringAssociatedWithAddress(result)

  if resultString != "":	
    #map the mach port name to the address of the objc dispatch call that assigned it.
    machPortMapDict[resultString] = {}
    machPortMapDict[resultString]["address"] = address
    #NOTE The following three lines of code are a liability that may cause crashes/errors. 
    #We might want to remove them if it isn't useful for mapping objects to mach ports
    arguments = getFuncArgs(address)
    argumentClass = arguments[0].split(" ")[0]
    machPortMapDict[resultString]["classGuess"] = argumentClass


    #TODO It should be helpful to also know the class used as the first argument in this function
    #This class may match nicely with the exposed class, which would make mapping easy.
  #I should consult the errorMessage log when we measure the accuracy of this tool.

#######################################################################
#Guess Exposed Object Name
#######################################################################
executableDict["exposedObjectMap"] = {}
exposedObjectMap = executableDict["exposedObjectMap"]
for address in getSelectorInvocations(selectorMap,"setExportedObject:"):
  #NOTE the normal backtracer usually fails at this, so we are using a heuristic for now based on IDA's inferred parameters
  #NOTE we can make this smarter or at least throw out obviously bad results by using results inferred by IDA.
  arguments = getFuncArgs(address)
  exportedClass = arguments[0].split(" ")[0]
  exposedObjectMap[exportedClass] = address

#######################################################################
#Get Exposed Method Names
#######################################################################
executableDict["exposedInterfaceMap"] = {}
exposedInterfaceMap = executableDict["exposedInterfaceMap"]
for address in getSelectorInvocations(selectorMap,"setExportedInterface:"):
  mach_service_targetReg = getRegisterNumber("X2")
  minEa = idc.GetFunctionAttr(address, idc.FUNCATTR_START)
  result = getRegisterValueAtAddress(address,minEa,mach_service_targetReg)
  protName = get_name(result)
  methodList = findMethodsOfProtocol(result)
  exposedInterfaceMap[protName] = {}
  exposedInterfaceMap[protName]["methodList"] = methodList
  exposedInterfaceMap[protName]["address"] = address

#######################################################################
#Clean up and infer mappings
#######################################################################

"""
f.write("filePath=" +filepathoniosdevice+"\n")
f.write("machPortMap= "+str(executableDict["machPortMap"])+"\n")
f.write("exposedObjectMap= "+str(executableDict["exposedObjectMap"])+"\n")
f.write("exposedInterfaceMap= "+str(executableDict["exposedInterfaceMap"])+"\n")

#TODO the following code should really be an independent script.
#	It may not even need to run IDA and could just be a normal python script


	f.write(filePath +",")
	f.write(machPortName +",")
	f.write(exposedObject +",")
	f.write(method+"\n")
"""

accessibleMachPortNames = open("./output/accessibleMachPortNames","r").read().strip().split("\n")
filePath = executableDict["filePath"]
for machPortName in executableDict["machPortMap"]:
  #if machPortName in accessibleMachPortNames:
  for exposedObject in executableDict["exposedObjectMap"]:
    for interface in executableDict["exposedInterfaceMap"]:
      for method in executableDict["exposedInterfaceMap"][interface]["methodList"]: 
	machClassGuess = executableDict["machPortMap"][machPortName]["classGuess"]
	if machClassGuess == exposedObject:
	  objFuncAddr = idc.GetFunctionAttr(executableDict["exposedObjectMap"][exposedObject], idc.FUNCATTR_START)
	  interfaceFuncAddr = idc.GetFunctionAttr(executableDict["exposedInterfaceMap"][interface]["address"], idc.FUNCATTR_START)
	  if objFuncAddr == interfaceFuncAddr:
	    if machPortName in accessibleMachPortNames:
	      f.write(filePath+",")
	      f.write(machPortName+",")
	      f.write(exposedObject+",")
	      f.write(method+"\n")

#if machPortName in accessibleMachPortNames:
	    
f.close()
with open(idc.ARGV[4], "wb") as f:
  pickle.dump(executableDict, f)
idc.Exit(0)
