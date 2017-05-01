fdata = open('plistsAndServices.out','r')
flines = fdata.read().strip().split('\n')

newData = ''

for line in flines:
  if '.plist' in line:
#    newData+=(line+',')
    continue
  else:
    newData+=(line+'\n')

print newData
