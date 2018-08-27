#!/bin/bash

cat << EOF
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
EOF

while IFS='' read -r line || [[ -n "$line" ]]; do
    key=`echo $line | cut -d "\"" -f10`
    value=`echo $line | cut -d "\"" -f12`
    type=`echo $line | cut -d "\"" -f11`
    echo "    <key>"$key"</key>"
    # For cases value([])
    if [[ $type = *"[]"* ]]; then
        continue
    fi
    # Handle Bool values
    if [[ $type = *"bool"* ]]; then
        echo "    <"$value"/>"
    # Handle String values
    elif [[ $type = *"value(string"* ]]; then
        echo "    <string>"$value"</string>"
    # Handle Array values
    elif [[ $type = *"value([string"* ]]; then
        echo "    <array>"
        arrayValues=`echo $line | cut -d "[" -f2 | cut -d "]" -f1`
        OLDIFS=$IFS
        IFS=',' list=($arrayValues)
        for elem in "${list[@]}"; do
            # process
            stringOfArray=`echo $elem | cut -d "\"" -f2`
            echo "        <string>"$stringOfArray"</string>"
        done
        IFS=$OLDSIFS
        echo "    </array>"
    fi
done < entitlementFactsWithPublic.pl 

cat << EOF
</dict>
</plist>
EOF
