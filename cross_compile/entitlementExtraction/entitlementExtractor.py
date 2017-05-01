import os
import re
import subprocess

for filename in os.listdir('rawEntitlements'):
  app = re.sub(r'\.app$',r'',filename)
  entitlements = open('rawEntitlements/'+filename,'r').read().strip().split('\n')
  for e in entitlements:
   if e != "":
    print app+','+e 
