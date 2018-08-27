#!/bin/bash

cat << EOF
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
EOF

ents=()
while IFS='\n' read -r line || [[ -n "$line" ]]; do
    if [[ $line != *"<key>"* ]]; then
        continue
    fi
    key=`echo $line | sed -n 's:.*<key>\(.*\)</key>.*:\1:p'` 
    ents+=($key)
done < allEntitlementsAndValues.xml

uniq_ents=`echo "${ents[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '`

for ent in ${uniq_ents[*]}
do
    awk -f extractEntWithFirstValue.awk -v key="$ent" < allEntitlementsAndValues.xml
done

cat << EOF
</dict>
</plist>
EOF
