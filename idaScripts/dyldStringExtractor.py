import idc
import idautils
from idaapi import *

f = open('dyldStrings.pl','w')

#why does this say False?
s = idautils.Strings(False)
s.setup(strtypes=Strings.STR_C)
for i, v in enumerate(s):
    if v is None:
        f.write("Failed to retrieve string index %d" % i)
    else:
        #f.write("%x: len=%d type=%d index=%d-> '%s'\n" % (v.ea, v.length, v.type, i, str(v)))
	seg=idc.SegName(v.ea)
	#I'm probably replacing more things than I should, but prolog is getting confused by random backslashes.
	currentString=str(v).replace("\n","").replace('"',"'").replace("\\","")
	#f.write("%s\n" % str(seg))
	f.write("dyldString(segment(\"%s\"),stringFromProgram(\"%s\")).\n" % (str(seg), currentString))

f.close()

idc.Exit(0)
