#!/usr/bin/env python

import yaml
from utils import *
import sys, os, subprocess

# Read config file
with open("config.yml", 'r') as ymlfile:
    cfg = yaml.load(ymlfile)

user = cfg['deviceInfo']['user']
host = cfg['deviceInfo']['host']
port = cfg['deviceInfo']['port']
deviceRootFolder = cfg['deviceInfo']['rootFolder']
extractFsFolder = cfg['outputFolders']['extractFsFolder']
dynamicOutputFolder = cfg['outputFolders']['dynamicOutputFolder']
startDynamicAnalysisScript = cfg['scripts']['startDynamicAnalysis']
stopDynamicAnalysisScript = cfg['scripts']['stopDynamicAnalysis']
staticAnalysisScript = cfg['scripts']['staticAnalysis']

# Create message to send
message = ""

# Parse arguments using ArgumentParser from utils
results = parser.parse_args()

if results.start_dynamic_analysis:
	print "################### Start Dynamic analysis ###################"
	subprocess.call([str(startDynamicAnalysisScript),
			 str(user),
			 str(host),
			 str(port),
			 str(dynamicOutputFolder)])
	message += "Start dynamic analysis \n"

if results.stop_dynamic_analysis:
	print "################### Start Dynamic analysis ###################"
	subprocess.call([str(stopDynamicAnalysisScript),
			 str(user),
			 str(host),
			 str(port),
			 str(dynamicOutputFolder)])
	message += "Stop dynamic analysis \n"

if results.static_analysis:
	print "################### Start Dynamic analysis ###################"
	subprocess.call([str(staticAnalysisScript),
			 str(user),
			 str(host),
			 str(port),
			 str(deviceRootFolder),
			 str(extractFsFolder)])
	message += "Static analysis \n"

if len(sys.argv) == 1:
	print "Please provide arguments. Use --help."
	sys.exit(0)

# Send mail that iOracle has finished.
if results.mail:
	sendMail(cfg['emailCredentials']['user'],
		 cfg['emailCredentials']['passwd'],
		 cfg['emailCredentials']['recipient'],
		 mailSubjectFinish,
		 message+mailMsgFinish)
