#!/bin/bash

#usage instructions
if test $# -ne 4; then
    echo "Usage: $0 input_directory_of_rootfs_dmg_files input_directory_of_dev_dmg_files directory_to_mount_in output_directory" 2>&1
    echo "Note that file paths must be absolute for this script to run properly (e.g., use this: /Users/luke/iOracle/dmg_files not this: ../dmg_files)" 2>&1
    exit 1
fi

#check for dependencies
if ! which gfind > /dev/null ; then
  echo "Error: This script requires gfind in order to execute. You can install it via 'brew install findutils'."
  exit 1;
fi

rootfs_dir="$1"
dev_dir="$2"
mount_dir="$3"
out_dir="$4"
mkdir $mount_dir
mkdir $mount_dir/rootfs
mkdir $mount_dir/dev
mkdir $mount_dir/temp
mkdir $out_dir


for rootfs in $rootfs_dir/*.dmg; 
do
  #we need a label that will reprensent the iOS version throughout the process
  basepath=`basename $rootfs .dmg`
  mkdir $out_dir/$basepath
  mkdir $out_dir/$basepath/prologFacts
  mkdir $out_dir/$basepath/fileSystem

  #mount the img using the label we created since we would otherwise have trouble predicting the resulting file path in /Volumes/
  echo mounting
  hdiutil attach -mountpoint $mount_dir/rootfs/$basepath $rootfs
  hdiutil attach -mountpoint $mount_dir/dev/$basepath $dev_dir/$basepath.dmg

  #copy the files while preserving all attributes including file ownership, permissions, and symlinks
  echo copying files 
  sudo cp -a $mount_dir/rootfs/$basepath $mount_dir/temp
  sudo cp -a $mount_dir/dev/$basepath/* $mount_dir/temp/$basepath/Developer/
  #this combination of actions will archive the files in the copied directory, but not the directory itself.
  
  #Get the metadata from the mounted file system. There is a lot more here than I expected.
  #we have to use a different metaDataExtractor since it needs to use gfind and needs to run it with sudo to get useful results.
  echo extracting file metadata
  #The filepaths for the mounted file system still include leading .'s representing the current directory, so we use sed to remove these.
  #This step was not necessary when running the metadata extractor on the iOS device because it was a completely isolated file system searched from its root.
  ./scriptsToAutomate/firmware_metaDataExtractor.sh $mount_dir/temp/$basepath | sed 's;),filePath("./;),filePath("/;' | sed 's;filePath(".");filePath("/");' | sort | uniq > $out_dir/$basepath/prologFacts/unsanitized_file_metadata.pl
  ./scriptsToAutomate/sanitizeFilePaths.py $out_dir/$basepath/prologFacts/unsanitized_file_metadata.pl > $out_dir/$basepath/prologFacts/file_metadata.pl

  #get group data
  ./scriptsToAutomate/firmware_group_extractor.py $mount_dir/temp/$basepath | sort | uniq > $out_dir/$basepath/prologFacts/group_membership_firmware.pl

  echo archiving files
  current_dir=`pwd`
  cd $mount_dir/temp/$basepath 
  sudo tar -zcf $out_dir/$basepath/fileSystem.tar.gz . 
  cd $current_dir
  #unmount by using the label we made and mounted with
  echo unmounting
  hdiutil detach $mount_dir/rootfs/$basepath
  hdiutil detach $mount_dir/dev/$basepath

  #TODO I should also delete the temp directory when we're done with it.
done
