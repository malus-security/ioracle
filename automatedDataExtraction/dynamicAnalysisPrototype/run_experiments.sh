#!/bin/bash

dry_run=0
if test $# -eq 5; then
    echo "Doing dry run"
    dry_run=1
else
    if test $# -ne 4; then
        echo "Usage: $0 storage_folder username host port [dry_run]" 1>&2
        exit 1
    fi
fi

storage_folder="$1"
username="$2"
hostname="$3"
port="$4"

# Create top-level folder if it doesn't exist.
test -d "$storage_folder" || mkdir "$storage_folder"

exercise_names=( \
    "install_app" \
    "alarm_clock" \
    "lock_device" \
    "save_photo_from_app" \
    "photo" \
    "settings" \
    "contacts" \
    "notes" \
    "phone" \
    "messages" \
    "map" \
    "reminders" \
    "health" \
    "wallet" \
    "memos" \
    "mail" \
    "find_iphone" \
    "books" \
    "copy_paste" \
    "calendar" \
    "find_friends" \
    "compass" \
    "safari" \
    "usb_plug" \
    "volume" \
    "power" \
    "backup"
    )

exercise_descriptions=( \
    "Install and uninstall an app from AppStore" \
    "Configure alarm clock" \
    "Lock and unlock device" \
    "Save photo create from a given app" \
    "Take photo, take video, view album, apply camera filter" \
    "Toggle settings in all possible ways without damaging device" \
    "Add, delete, edit, share contacts" \
    "Add, delete, edit, notes, create note folder" \
    "Make call, receive call, set up voice e-mail, edit favorites" \
    "Create, edit, delete, send, receive messages" \
    "Get directions, add place, mark location" \
    "Create, edit, share, delete a reminder, trigger a reminder, toggle priority" \
    "Play with health settings" \
    "Play with wallet" \
    "Create, edit, share, remove a memo" \
    "Add/Remove e-mail account, send/receive e-mail" \
    "Configure find my iPhone" \
    "Play with iBooks app" \
    "Copy and paste text from one app to the other app" \
    "Create/delete/edit/share calendar entry, send/receive invitation" \
    "Play with find friends extra" \
    "Play with compass" \
    "Enter site, create favorite site, open/close tabs open app in app store, delete history, do private browsing" \
    "Plug into and unplug USB to desktop" \
    "Adjust volume, mute sound" \
    "Connect/Disconnect from power source" \
    "Do backup on iCloud"
    )

for i in $(seq 0 $((${#exercise_names[@]}-1))); do
    ce="${exercise_names[$i]}"
    de="${exercise_descriptions[$i]}"
    path="$storage_folder/$ce"
    echo -e "\n------------------------------"
    echo -e "Running exercise '$ce' and storing data in '$path'\n"
    if test "$dry_run" == 0; then
        ./startDynamicAnalysis.sh "$username" "$hostname" "$port" "$path"
    fi
    echo "INSTRUCTIONS: $de"
    echo -e "\n\nPress ENTER after completing the exercise\n"
    read line
    echo "Please wait to retrieve and process files"
    if test "$dry_run" == 0; then
        ./stopDynamicAnalysis.sh "$username" "$hostname" "$port" "$path"
    fi
    echo "------------------------------"
done
