#!/bin/bash
otool -L "$@" > usedFrameworks.output

echo "$@"

cat usedFrameworks.output | grep '(' | sed s/\ .*// | sed s/.*[/]// > justFrameWorks.out

while read p; do
  sqlite3 apps_Frameworks_Services.db "insert into frameworks (app,framework) values ('$@','$p');"
done < justFrameWorks.out

while read p; do
  array=(${p//,/ })
  for i in "${!array[@]}"
  do
    if grep -q ${array[i]} usedFrameworks.output; then
      sqlite3 apps_Frameworks_Services.db "insert into machServices (app,service) values ('$@','${array[0]}');"
      break
    fi
  done
done < machServicesInSections.csv
rm usedFrameworks.output
rm justFrameWorks.out
