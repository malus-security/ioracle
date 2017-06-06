#!/usr/bin/env python

import yaml
from utils import *
import sys

# Read config file
with open("config.yml", 'r') as ymlfile:
    cfg = yaml.load(ymlfile)

# Create message to send
message = ""

# Parse arguments using ArgumentParser from utils
results = parser.parse_args()

if results.start_dynamic_analysis:
	print "Dynamic analysis"
	message += "Start dynamic analysis \n"
if results.stop_dynamic_analysis:
	print "Stop Dynamic analysis "
	message += "Stop dynamic analysis \n"
if results.static_analysis:
	print "Static analysis"
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
