import re
import sys

"""	Replace ViewController.m file from below and redirect it to a new
	ViewController.m file that will be fuzzed
"""

singleton=True
with open('ViewController.m', 'rt') as sourceFile:
  for line in sourceFile:
    intVar = re.search('^(unsigned )?int var_.*_.*;$', line)
    longVar = re.search('^(unsigned )?(long )?long var_.*_.*;$', line)
    stringVar = re.search('^NSString \* var_.*_.*;$', line)
    arrayVar = re.search('^NSArray \* var_.*_.*;$', line)
    boolVar = re.search('^_Bool var_.*_.*;$', line)
    errorVar = re.search('^NSError \* var_.*_.*;$', line)
    dataVar = re.search('^NSData \* var_.*_.*;$', line)
 
    if intVar:
      print "%s = -1;" % intVar.group()[:-1]
    elif longVar:
      print "%s = -1;" % longVar.group()[:-1]
    elif stringVar:
      print '%s = @"Simple Var";' % stringVar.group()[:-1]
    elif arrayVar:
      print '%s = [NSArray arrayWithObjects:@"key1",@"key2",@"key3",nil];' % arrayVar.group()[:-1]
    elif boolVar:
      print '%s = "False";' % boolVar.group()[:-1]
    elif errorVar:
      print '%s = nil;' % errorVar.group()[:-1]
    elif dataVar:
      if singleton:
        print 'void * bytes = malloc(1024);'
        singleton=False
      else:
        print 'bytes = malloc(1024);'
      print '%s = [NSData dataWithBytes:bytes length:1024];' % dataVar.group()[:-1]
      print 'free(bytes);'
    else:
      sys.stdout.write(line)

