#three input files, 1) mach-port to exec mapping, 2) protocol to exec mapping, 3) list of accessible mach-ports
#one output file, mapping of protocols that might be related to accessible mach-ports
#bonus output, mapping of specific methods to try for each accessible mach-port

import pickle
import re

def handleBlockArgument(blockParameter):
  argsToReturn = []
  pattern = re.compile("(.*)\ \(\^\)\((.*)\)")
  match = pattern.match(blockParameter)
  argsToReturn.append(match.group(1))
  #print argsToReturn
  if ", " in match.group(2):
    argsToReturn += match.group(2).split(", ")
  else:
    argsToReturn.append(match.group(2))
  return argsToReturn

def getReturnType(declaration):
  pattern = re.compile(".*?\(([^)]*)")
  match = pattern.match(declaration)
  return_type = match.group(1)
  return return_type

def getParameterTypes(method):
  argsToReturn = []
  raw_arguments = method.split(':')[1:]
  for argument in raw_arguments:
    pattern = re.compile("\((.*)\)")
    match = pattern.match(argument)
    arg_type = match.group(1)

    if "(^)" in arg_type:
      argsToReturn.append(handleBlockArgument(arg_type))
    else:
      argsToReturn.append(arg_type)
  return argsToReturn

def autoCodeThisMethod(method, machPort, id):
  objcCode = ""
  id = str(id)
  #loadProtocol
  fake_protocol_name = "fakeProts"
  objcCode += "NSXPCInterface *myInterface_"+id+" = [NSXPCInterface interfaceWithProtocol: @protocol("+fake_protocol_name+")];\n"
  #initialize connection
  objcCode += 'NSXPCConnection *myConnection_'+id+' = [[NSXPCConnection alloc] initWithMachServiceName:@"'+machPort+'"options:0];\n'
  objcCode += 'myConnection'+id+'.remoteObjectInterface = myInterface_'+id+';\n'
  objcCode += '[myConnection_'+id+' resume];\n'
  #handle error messages
  objcCode += 'myConnection_'+id+'.interruptionHandler = ^{NSLog(@"Connection Terminated for id:'+id+'");};\n'
  objcCode += 'myConnection_'+id+'.invalidationHandler = ^{NSLog(@"Connection Invalidated for id:'+id+'");};\n'


  #extract return and argument types
  varTypes = []
  varTypes.append(getReturnType(method))
  varTypes += getParameterTypes(method)
  print method
  print varTypes 
  for var in varTypes:
    


  #declare method parameters by iterating through argument type list.
  #I don't think we actually need to initialize these parameters, I think they just need to be declared.
    #check for block parameters
    #set up blocks if necessary
  #invoke the method using initialized parameters



  return objcCode
  


def prettyPrint(executableDict):
  for executable in executableDict:
    print executable
    print "  mach-port: " + executableDict[executable]["mach-port"]
    if "protocols" in executableDict[executable]:
      protsDict = executableDict[executable]["protocols"] 
      if len(protsDict) == 1:
        print "GOOD FOR TESTING"
      for protocol in protsDict:
        print "  protocol: " + protocol
        for method in protsDict[protocol]:
          print "    method: " + method

executableDictionary = {}

#map sandbox accessible mach-ports to executables
machPort_to_Exec_Mappings = open("./input_data/mach-port_to_executable.txt", "rb").read().strip().split("\n")
sandboxAccessibleMachPorts = open("./input_data/sandbox_accessible_services.txt", "rb").read().strip().split("\n")
#print machPort_to_Exec_Mappings
for mapping in machPort_to_Exec_Mappings: 
  machPort, executable = mapping.split(",")
  if machPort in sandboxAccessibleMachPorts:
    executableDictionary[executable] = {}
    executableDictionary[executable]["mach-port"] = machPort

print executableDictionary

#map protocols to executables
with open('./input_data/mystery_pickle_file.pk', 'rb') as handle:
    class_dump_results = pickle.load(handle)

for executable in executableDictionary:
  if class_dump_results[executable] != {}:
    executableDictionary[executable]["protocols"] = {}
    protsDict = executableDictionary[executable]["protocols"] 
    for protocol in class_dump_results[executable]:
      protsDict[protocol] = []
      raw_header = class_dump_results[executable][protocol]
      for line in raw_header.split('\n'):
        if line.endswith(";"):
          protsDict[protocol].append(line)

#for each executable in executableDict, search through the pickle dictionary for protocols.
#if any protocols are found, then add them to executable's dictionary.
# executable {mach-port: ..., protocols: {protocol: [methodDeclarationStrings]}}

prettyPrint(executableDictionary)

id = 1
for executable in executableDictionary:
  if "protocols" in executableDictionary[executable]:
    protsDict = executableDictionary[executable]["protocols"] 
    for protocol in protsDict:
      for method in protsDict[protocol]:
        machPort = executableDictionary[executable]["mach-port"] 
        objcCode = autoCodeThisMethod(method, machPort, id)
        id += 1
        print objcCode


