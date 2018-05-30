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

  if result == 0x0:
    continue

  resultString = findStringAssociatedWithAddress(result)

  if resultString != "":	
    #map the mach port name to the address of the objc dispatch call that assigned it.
    machPortMapDict[resultString] = {}
    machPortMapDict[resultString]["address"] = address
    """
    #NOTE The following three lines of code are a liability that may cause crashes/errors. 
    #We might want to remove them if it isn't useful for mapping objects to mach ports
    arguments = getFuncArgs(address)
    argumentClass = arguments[0].split(" ")[0]
    machPortMapDict[resultString]["classGuess"] = argumentClass
    """

    #TODO It should be helpful to also know the class used as the first argument in this function
    #This class may match nicely with the exposed class, which would make mapping easy.
  #I should consult the errorMessage log when we measure the accuracy of this tool.

"""
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
"""

#######################################################################
#Get Exposed Method Names and Method Arguments
#######################################################################
executableDict["exposedInterfaceMap"] = {}
exposedInterfaceMap = executableDict["exposedInterfaceMap"]
#for address in getSelectorInvocations(selectorMap,"setExportedInterface:"):
for address in getSelectorInvocations(selectorMap,"interfaceWithProtocol:"):
  mach_service_targetReg = getRegisterNumber("X2")
  minEa = idc.GetFunctionAttr(address, idc.FUNCATTR_START)
  result = getRegisterValueAtAddress(address,minEa,mach_service_targetReg)
  #sometimes we fail to find the parameter.
  #we can fix these cases later, but for now we should focus on low hanging fruit.
  if result == 0x0:
    continue
  protName = get_name(result)
  methodList = findMethodsOfProtocol(result, verbose=False)
  exposedInterfaceMap[protName] = {}
  exposedInterfaceMap[protName]["methodList"] = methodList
  exposedInterfaceMap[protName]["address"] = address
  exposedInterfaceMap[protName]["requiredEntitlements"] = []

  #get arguments for each exposed method
  exposedInterfaceMap[protName]["methodDict"] = {}
  methodDict = exposedInterfaceMap[protName]["methodDict"] 
  for method in exposedInterfaceMap[protName]["methodList"]: 
    methodDict[method] = {}
    methodDict[method]["arguments"] = []
    methodDict[method]["requiredEntitlements"]=[]
    #find the function(s) matching the given selector (this should become a function) 
    for funkyAddress in idautils.Functions():
      funkyName = get_name(funkyAddress)
      #if there is a space in the function's name, then split and take the second half as the selector
      if " " in funkyName:
	funkySpaceList = funkyName.split(" ")
	funkySelector = funkySpaceList[1][:-1]
	if method == funkySelector:
	  funkyArguments = getFuncArgs(funkyAddress)[2:]
	  if funkyArguments not in methodDict[method]["arguments"]:
	    methodDict[method]["arguments"].append(funkyArguments)
	
#######################################################################
#Get Easy to Spot Entitlement Checks
#######################################################################
executableDict["entitlementChecks"] = {}
entitlementMap= executableDict["entitlementChecks"]

for address in getSelectorInvocations(selectorMap,"valueForEntitlement:"):
  mach_service_targetReg = getRegisterNumber("X2")
  minEa = idc.GetFunctionAttr(address, idc.FUNCATTR_START)
  result = getRegisterValueAtAddress(address,minEa,mach_service_targetReg)
  #sometimes we fail to find the parameter.
  #we can fix these cases later, but for now we should focus on low hanging fruit.
  if result == 0x0:
    continue

  resultString = findStringAssociatedWithAddress(result)

  if resultString != "":	
    #map the mach port name to the address of the objc dispatch call that assigned it.
    entitlementMap[resultString] = {}
    entitlementMap[resultString]["address"]= hex(address)
    #try to pair the entitlement to a prototype
    for interface in executableDict["exposedInterfaceMap"]:
      funky_interface_start = idc.GetFunctionAttr(exposedInterfaceMap[interface]["address"], idc.FUNCATTR_START)
      funky_entCheck_start = idc.GetFunctionAttr(address, idc.FUNCATTR_START)
      if funky_interface_start == funky_entCheck_start:
	executableDict["exposedInterfaceMap"][interface]["requiredEntitlements"].append(resultString)
      for method in executableDict["exposedInterfaceMap"][interface]["methodList"]: 
	reqEntList = executableDict["exposedInterfaceMap"][interface]["methodDict"][method]["requiredEntitlements"]
	funkyName = get_name(funky_entCheck_start)
	#if there is a space in the function's name, then split and take the second half as the selector
	if " " in funkyName:
	  funkySpaceList = funkyName.split(" ")
	  funkySelector = funkySpaceList[1][:-1]
	  if method == funkySelector:
	    reqEntList.append(resultString)

	
      

#######################################################################
#Clean up and infer mappings
#######################################################################

#we should only care about mach port names, methods, and arguments.
#having the exposed object doesn't help very much aside from resolving some ambiguity for shared selectors.
accessibleMachPortNames = open("./output/accessibleMachPortNames","r").read().strip().split("\n")
filePath = executableDict["filePath"]
for machPortName in executableDict["machPortMap"]:
  #we only care about those mach ports we can access through the sandbox
  #TODO update this list with exceptions for entitled apps (should add two more)
  if machPortName in accessibleMachPortNames:
    for interface in executableDict["exposedInterfaceMap"]:
      for method in executableDict["exposedInterfaceMap"][interface]["methodList"]: 
	for argumentList in executableDict["exposedInterfaceMap"][interface]["methodDict"][method]["arguments"]: 
	  reqEntsProt = executableDict["exposedInterfaceMap"][interface]["requiredEntitlements"]
	  reqEntsMethod = executableDict["exposedInterfaceMap"][interface]["methodDict"][method]["requiredEntitlements"]
	  f.write(filePath+",")
	  f.write("[todo_UseiOracleQuery],")
	  f.write(machPortName+",")
	  f.write(interface+",")
	  f.write(str(reqEntsProt).replace(",",";")+",")
	  f.write(method+",")
	  f.write(str(reqEntsMethod).replace(",",";")+",")
	  f.write(str(argumentList).replace(",",";")+"\n")

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
	    #if machPortName in accessibleMachPortNames:
	      f.write(filePath+",")
	      f.write(machPortName+",")
	      f.write(exposedObject+",")
	      f.write(method+"\n")
"""

	    
f.close()
with open(idc.ARGV[4], "wb") as f:
  pickle.dump(executableDict, f)
idc.Exit(0)
