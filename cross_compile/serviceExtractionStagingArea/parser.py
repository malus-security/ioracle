from xml.dom import minidom
import sys

if __name__ == "__main__":
	args  = sys.argv
	fileName = args[1]
	xmldoc = minidom.parse(fileName)
	plistNode = xmldoc.childNodes[1]
	topDictNode = plistNode.childNodes[1]
	#variable for finding the index of dict eelement after MachServices
	indexMachServices = -1
	machServicesNode = None
	for dictNodes in topDictNode.childNodes:
		indexMachServices = indexMachServices + 1
		if dictNodes.nodeType == dictNodes.ELEMENT_NODE:
			if dictNodes.tagName == "key":
				dictNodesData = dictNodes.firstChild.data
				if dictNodesData == "MachServices":
					indexMachServices = indexMachServices + 2
					machServicesNode =  topDictNode.childNodes[indexMachServices]
					break
	if machServicesNode != None:
		for machServicesNodes in machServicesNode.childNodes:
			if machServicesNodes.nodeType == machServicesNodes.ELEMENT_NODE:
				if machServicesNodes.tagName == "key":
					print fileName 
					print machServicesNodes.firstChild.data
#			textNode = dictNodes.firstChild
#			if textNode.nodeType == textNode.TEXT_NODE:
#				print textNode.data
#			print dictNodes.toxml()
