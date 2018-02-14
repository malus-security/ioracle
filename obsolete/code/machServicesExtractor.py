from xml.dom import minidom
import sys
import re


def split_file(infile, result):
  with open(infile) as fp:
    for job in re.findall('<?xml(.*?)</plist>', fp.read(), re.S):
      result.append(job)

def parse_one(xml):
  xmldoc = minidom.parseString(xml)
  plistNode = xmldoc.childNodes[1]
  topDictNode = plistNode.childNodes[1]
  #variable for finding the index of dict eelement after MachServices
  indexMachServices = -1
  indexLabel = -1
  machServicesNode = None
  process = ''
  mach_services = []

  for dictNodes in topDictNode.childNodes:
    indexMachServices = indexMachServices + 1
    indexLabel = indexLabel + 1
    if dictNodes.nodeType == dictNodes.ELEMENT_NODE:
      if dictNodes.tagName == "key":
        dictNodesData = dictNodes.firstChild.data
        if dictNodesData == "Label":
          indexLabel = indexLabel + 2
          process = topDictNode.childNodes[indexLabel]
        if dictNodesData == "MachServices":
          indexMachServices = indexMachServices + 2
          machServicesNode =  topDictNode.childNodes[indexMachServices]
          break

  if process and machServicesNode:
    sys.stdout.write("mach(")
    if process.tagName == "string":
      sys.stdout.write("pId(\"" + process.firstChild.data + "\"),machServices(")
  if machServicesNode != None:
    for machServicesNodes in machServicesNode.childNodes:
      if machServicesNodes.nodeType == machServicesNodes.ELEMENT_NODE:
        if machServicesNodes.tagName == "key":
          mach_services.append(machServicesNodes.firstChild.data)
    sys.stdout.write("[%s])).\n" % ','.join('"' + ms + \
                     '"' for ms in mach_services))

if __name__ == "__main__":
  args  = sys.argv
  jobs_file = args[1]
  details = []

  split_file(jobs_file, details)
  full_list = list("<?xml" + d + "</plist>" for d in details)

  for e in full_list:
    parse_one(e)
