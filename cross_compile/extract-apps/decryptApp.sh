#!/bin/bash
#I used port 2223 because 2222 seems broken on my laptop...
IFC=$(ssh root@localhost -p 2223 '[[ ! -f /var/root/mihaiApps/Clutch ]] && printf "OK\n" ')
if [ "$IFC" == "OK" ]
  then
    echo "Installing Clutch"
    curl -O http://itacad.ro/pages/Clutch
    ssh root@localhost -p 2223 'mkdir -p /var/root/mihaiApps/'
    scp -P 2223 Clutch root@localhost:/var/root/mihaiApps/Clutch
    ssh root@localhost -p 2223 'chmod +x /var/root/mihaiApps/Clutch'
fi
	
echo "Sending app to phone"
scp -P 2223 "$1" root@localhost:/var/root/

echo "Installing app on the phone"
ssh root@localhost -p 2223 'ipainstaller -l' > temp.before
ssh root@localhost -p 2223 'ipainstaller -c -f "/var/root/'$1'"' > app.install

echo "Decrypting app"
ssh root@localhost -p 2223 'ipainstaller -l' > temp.after
ssh root@localhost -p 2223 '/var/root/mihaiApps/Clutch -i' > clutch.apps
cat clutch.apps
id=$(diff temp.before temp.after | grep ">" | cut -d " " -f 2)

appName=$(grep $id clutch.apps | sed "s/.*<//" | sed "s/\ bundleID:\ .*//")
#for word in $(cat app.install | grep Installing)
#do
#  if grep -q $word clutch.apps; then
#    appName="$appName $word"
#  fi
#done 
#appName=$(echo $appName | sed 's/^ *//g')
echo the app name is $appName
#appNumber=$(cat clutch.apps | grep "$appName" | cut -d" " -f 2  | cut -d":" -f 1)
ssh root@localhost -p 2223 '/var/root/mihaiApps/Clutch -d "'$id'"' > clutch.decrypt 2>&1

echo "Downloading app from phone"
appDecryptFile=$(cat clutch.decrypt | grep DONE | cut -d":" -f 2 | sed 's/^ *//g')
echo $appDecryptFile
cat clutch.decrypt
scp -P 2223 root@localhost:"'$appDecryptFile'" app.ipa

echo "Extracting app binary"
mkdir -p unzip
unzip app.ipa -d unzip/
mkdir -p decryptedApps
echo $appName
for f in unzip/Payload/"$appName.app"/*
do
  fileType=$(file "$f")
  if [[ $fileType == *"executable"* ]]
  then
    echo $f
    cp "$f" decryptedApps/.
  fi
done

echo "Cleaning phone"
ssh root@localhost -p 2223 'rm -f "/var/root/'$1'"'
ssh root@localhost -p 2223 'ipainstaller -u "'$id'"'

echo "Cleaning local directory"
rm -rf temp.before temp.after app.install clutch.apps unzip clutch.decrypt app.ipa
mv "$1" alreadyDecrypted
echo "$1,$appName" >> ipaToBinaryMapping.csv
ssh root@localhost -p 2223 'rm /private/var/mobile/Documents/Cracked/*.ipa'
