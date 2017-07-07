#!/bin/bash

#usage instructions
if test $# -ne 3; then
    echo "Usage: $0 input_directory_of_img_files directory_to_mount_img_in output_directory" 2>&1
    exit 1
fi

#check for dependencies
if ! which gfind > /dev/null ; then
  echo "Error: This script requires gfind in order to execute. You can install it via 'brew install findutils'."
  exit 1;
fi

in_dir="$1"
mount_dir="$2"
out_dir="$3"
mkdir $mount_dir
mkdir $out_dir


for filename in $in_dir/*.img; 
do
  #we need a label that will reprensent the iOS version throughout the process
  basepath=`basename $filename .rootfs.img`
  mkdir $out_dir/$basepath
  mkdir $out_dir/$basepath/prologFacts
  mkdir $out_dir/$basepath/fileSystem

  #mount the img using the label we created since we would otherwise have trouble predicting the resulting file path in /Volumes/
  echo mounting
  hdiutil attach -mountpoint $mount_dir/$basepath $filename

  #copy the files while preserving all attributes including file ownership, permissions, and symlinks
  #echo copying files 
  #sudo cp -a $mount_dir/$mount_point $out_dir/ 
  #this combination of actions will archive the files in the copied directory, but not the directory itself.
  
  #Get the metadata from the mounted file system. There is a lot more here than I expected.
  #we have to use a different metaDataExtractor since it needs to use gfind and needs to run it with sudo to get useful results.
  echo extracting file metadata
  #The filepaths for the mounted file system still include leading .'s representing the current directory, so we use sed to remove these.
  #This step was not necessary when running the metadata extractor on the iOS device because it was a completely isolated file system searched from its root.
  ./scriptsToAutomate/firmware_metaDataExtractor.sh $mount_dir/$basepath | sed 's;),filePath("./;),filePath("/;' | sed 's;filePath(".");filePath("/");' | sort | uniq > $out_dir/$basepath/prologFacts/unsanitized_file_metadata.pl
  ./scriptsToAutomate/sanitizeFilePaths.py $out_dir/$basepath/prologFacts/unsanitized_file_metadata.pl > $out_dir/$basepath/prologFacts/file_metadata.pl

  echo archiving files
  cd $mount_dir/$basepath && sudo tar -zcf ../../$out_dir/$basepath/fileSystem.tar.gz . && cd ../..
  #unmount by using the label we made and mounted with
  echo unmounting
  hdiutil detach $mount_dir/$basepath
done
