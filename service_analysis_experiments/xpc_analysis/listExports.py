import pickle

filePathOniOSDevice=idc.ARGV[1]
outputFile=idc.ARGV[2]
errorMessage = ""

exportDictionary = {}

exportList = list(idautils.Entries()) 
for export in exportList:
  exportAddress = export[1]
  exportName = export[3]
  exportString = findStringAssociatedWithAddress(exportAddress)
  #since we're only looking for entitlements and mach service names, it should be safe to remove problematic characters.
  if exportString != "" and exportString != None:
    exportString = exportString.replace("\n","")
    exportString = exportString.replace(",","")
    #f.write("exportedFromDyld(eAddress(\""+str(hex(exportAddress))+"\")).\n")
    #TODO there is some syntax error here. find it.
    exportDictionary[exportName] = exportString

pickle.dump(exportDictionary, open(outputFile, "wb" ))

idc.Exit(0)
