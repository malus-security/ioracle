filePathOniOSDevice=idc.ARGV[1]
#I can use argument 4 as a per executable dictionary
outputFile=idc.ARGV[4]
export_dict_file = idc.ARGV[3]
export_dict = pickle.load(open(export_dict_file, "rb"))
targetReg = getRegisterNumber("X1")
errorMessage = ""
#run this in a for loop and scan every objc_msgSend
#also parse the result such that an actual string is output.

#for these interactive tests, we will start with an empty dictionary.
#otherwise, we would load any existing dictionary for the executable first.

try:
  with open(outputFile, "rb") as f:
    executableDict = pickle.load(f)
except (OSError, IOError) as e:
  executableDict = {}

#We need to delete any existing objc selector mappings, but keep any other information in tact.
executableDict["selectorMap"] = {}
selectorMap = executableDict["selectorMap"] 

functionName = "_objc_msgSend"
for nName in idautils.Names():
  
  name = nName[1]
  if functionName == name:
    nameAddress = nName[0]
    #now that we have the address of the name we can look for a cross reference.
    for xref in idautils.XrefsTo(nameAddress, 0):
      ea = xref.frm
      minEa = idc.GetFunctionAttr(ea, idc.FUNCATTR_START)
      #We are definitely getting a lot of errors here, but I think we are still finding the selectors we need.

      try:
	selectorAddress = getRegisterValueAtAddress(ea,minEa,targetReg)
      except RuntimeError as runErr:
	if runErr.args[0] != 'maximum recursion depth exceeded':
        # different type of runtime error
	  raise
	else: 
	  print 'Recursion Explosion: ' + str(hex(ea))

      selString = findStringAssociatedWithAddress(selectorAddress)
      if selString != "":
	if selString in selectorMap:
	  selectorMap[selString].append(ea)
	else:
	  selectorMap[selString] = [ea]

with open(outputFile, "wb") as f:
  pickle.dump(executableDict, f)
idc.Exit(0)
