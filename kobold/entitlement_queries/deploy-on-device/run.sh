#!/bin/bash

. run.config

function error_exit {
    echo "$1"
    exit "${2:-1}"  ## Return a code specified by $2 or 1 by default.
}

function execute_on_device {
    ssh $user@$ip_addr $1
}

#Make sure device is available
output=$(ping $ip_addr -c 1 -t 1) || error_exit "Device not found"

# Download filemon and use it
#output=$(ssh $user@$ip_addr filemon -h) || error_exit "Filemon not found"

#Start filemon
echo "Start filemon"
execute_on_device ./filemon > filemon.txt &

#Run app
echo "Start app"
./all.sh $binary_app $ent_file $user@$ip_addr

# Terminate filemon
pkill ssh

output=$(ls run.out) || error_exit "No output file"

echo "Adding logs to db"
python -c 'import createLogsDatabase as db; db.add_log("run.out")'
#python -c 'import createLogsDatabase as db; db.insert_run("'$model'", "'$iOS'", "'$jailbroken'", "'$ent_file'", "run.out", db.get_runID())'

