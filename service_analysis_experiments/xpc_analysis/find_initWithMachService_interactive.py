targetReg = getRegisterNumber("X1")
errorMessage = ""
export_dict = pickle.load( open( "/home/ladeshot/iOracle/service_analysis_experiments/xpc_analysis/output/exports.p", "rb" ) )
executableDict = pickle.load( open( "/home/ladeshot/iOracle/service_analysis_experiments/xpc_analysis/output/dictionary_terminal_test", "rb" ) )
#run this in a for loop and scan every objc_msgSend
#also parse the result such that an actual string is output.

for selector in executableDict["selectorMap"]:
  if selector.startswith("initWithMachServiceName:"):
    for address in executableDict["selectorMap"][selector]:
      print "Found target at: " + str(hex(address))[:-1]
      mach_service_targetReg = getRegisterNumber("X2")

      minEa = idc.GetFunctionAttr(address, idc.FUNCATTR_START)
      result = getRegisterValueAtAddress(address,minEa,mach_service_targetReg)
      resultString = findStringAssociatedWithAddress(result)

      print resultString
      if errorMessage != "":
	print errorMessage
