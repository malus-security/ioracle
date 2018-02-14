#!/usr/bin/env python

import argparse
import smtplib
from email.MIMEMultipart import MIMEMultipart
from email.MIMEBase import MIMEBase
from email.MIMEText import MIMEText

mailSubjectFinish = '[iOracle] Status: Finish'
mailMsgFinish = 'The above iOracle scripts are finished.'


def sendMail(user, passwd, recipient, subject, message):
	msg = MIMEMultipart()

	msg['From'] = user
	msg['To'] = recipient
	msg['Subject'] = subject

	msg.attach(MIMEText(message))

	mailServer = smtplib.SMTP("smtp.gmail.com", 587)
	mailServer.ehlo()
	mailServer.starttls()
	mailServer.ehlo()
	mailServer.login(user, passwd)
	mailServer.sendmail(user, recipient, msg.as_string())


# Handle arguments
parser = argparse.ArgumentParser()
parser.add_argument('--start-dynamic-analysis',
		    action='store_const',
		    dest='start_dynamic_analysis',
		    const='start_dynamic_analysis',
		    help='Starts dynamic analysis. '
		    'After that, you should start using the device to '
		    'generate file accesses.')
parser.add_argument('--stop-dynamic-analysis',
		    action='store_const',
		    dest='stop_dynamic_analysis',
		    const='stop_dynamic_analysis',
		    help='Stops dynamic analysis '
		    'and collects the data from the device.')
parser.add_argument('--static-analysis',
		    action='store_const',
		    dest='static_analysis',
		    const='static_analysis',
		    help='Starts the static analysis. ')
parser.add_argument('--mail',
		    action='store_const',
		    dest='mail',
		    const='mail',
		    help='Sends mail when the scripts are finished. '
		    'Please remember to add your e-mail to config.yml file')

args = parser.parse_args()
