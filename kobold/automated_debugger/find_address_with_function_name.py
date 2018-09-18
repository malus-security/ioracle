#we'll want a good regular expression to remove the variable types.
#it seems that name of the function does not include the variable types or names.
#for example:
# - (void)startMonitoringScenarioTriggerOfType:(unsigned long long)arg1 forClient:(byref id <CLRoutineMonitorClientProtocol>)arg2;
# startMonitoringScenarioTriggerOfType:forClient:
#perhaps duplicates will be possible, but we can add a sanity check to see if that happens and deal with it later.

import idaapi
import idc
import idautils
import os
import pickle
import re

functionName = "startMonitoringScenarioTriggerOfType:forClient:"
for nName in idautils.Names():
  name = nName[1]
  if functionName in name:
    nameAddress = nName[0]
    if idc.get_segm_name(nameAddress) == "__text":
      print "address of function is: ",
      print str(hex(nameAddress))[:-1]

#pickle.dump(executableDict, open("/home/ladeshot/iOracle/kobold/automated_debugger/daemon_protocol_addresses", "wb"))
