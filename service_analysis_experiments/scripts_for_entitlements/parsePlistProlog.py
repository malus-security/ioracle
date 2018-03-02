#!/usr/bin/python

#This script extracts meta-data from an app ipa file by parsing the app's iTunesMetadata.plist.
#This data is useful in determining the developer of a file (Apple or third party) and helps map app data to a familiar app name.

import os
import sys
import plistlib

#Usage
if len(sys.argv) < 2:
  print "Usage: ./parsePlist.py extractedAppDirectory/iTunesMetadata.plist"
  exit()

#arguments
inputFile = sys.argv[1]

#set up header so we might turn this into a csv file 
#outputFile.write("itemID;;;;;itemName;;;;;artistName;;;;;softwareVersionBundleId;;;;;\n")

pl = plistlib.readPlist(inputFile)
#just name the key you want to look up, and the associated value is returned.
itemId = str(pl['itemId'])
artistName = pl['artistName'].encode('utf-8')
if artistName != "Apple":
  artistName = "thirdPartyDeveloper"
bundleId = pl['softwareVersionBundleId'].encode('utf-8')

print 'appStoreEntitlement(itemId("' + itemId + '"),artistName("' + artistName + '"),bundleId("' + bundleId + '")'
