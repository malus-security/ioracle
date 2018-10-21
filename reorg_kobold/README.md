# Kobold Reorganization
This directory represents a reorganization of the kobold project which has expanded to include many obsolete scripts.
It should only include scripts the scripts we would include if we were to open source the project.
Experimental efforts should be run in directories labelled "experiment\_" and moved to proper directories when the code is stable.

I am assuming this process is being performed on a macOS device. Many steps can be replicated in Linux, but eventually you will need to run Xcode, which definitely requires macOS.

## Step 1. Extract data for iOS firmware version.
Use iExtractor to extract the file system, sandbox profiles, etc. from the iOS version you want to investigate.
Take the output results of iExtractor and store them in `kobold_reorg/data_from_iextractor/`.
For example:

`mv iExtractor_Results/out/iPhone_4.0_64bit_11.1.2_15B202 kobold_reorg/data_from_iextractor/iPhone_4.0_64bit_11.1.2_15B202`

## Step 2. Compile SBPL Sandbox Profiles into Prolog Facts.
Use SandScout to compile the sandbox profiles produced by iExtractor into Prolog facts that can be used by iOracle.
Unfortunately our SandScout automation scripts make a lot of assumptions about directories, so we need to give exact paths. 
For Example:

```
gitHome=\`git rev-parse --show-toplevel\`
cd $gitHome/sandscout
myiOSData=$gitHome/reorg_kobold/data_from_iextractor/iPhone_4.0_64bit_11.1.2_15B202
./processAllProfiles.sh $myiOSData/reversed_profiles $myiOSData/individual_profiles_prolog $myiOSData/consolidated_sb_facts.pl
```

TODO: The cascades server is currently down, so I will need to wait before transplanting some other sandbox profiles. I can work on extracting mach ports from caches in the meantime.

## Step 3. Unpack the filesystem extracted with iExtractor
Make a directory to store the unpacked file system.
Then unpack the tar file that iExtractor produced.

```
cd data_from_iextractor/iPhone_4.0_64bit_11.1.2_15B202/
mkdir filesystem
tar -xzf fs.tar.gz -C filesystem/
```

## Step 4. Extract mach port to executable mapping from cached configuration files.
Copy the cached config files into a directory for processing:

```
cd data_from_iextractor/iPhone_4.0_64bit_11.1.2_15B202/
mkdir machport_to_exec_mapping_dir
cp filesystem/System/Library/Caches/com.apple.xpcd/xpcd_cache.dylib ./machport_to_exec_mapping_dir/xpcd_cache.dylib
```

Use jtool to list the libraries in the xpcd\_cache.dylib file (note the .dylib extension).
There should be a section named `__TEXT.__xpcd_cache`, which we can extract with jtool.
Note that jtool will extract the section into whatever your current directory is.
The resulting file is actually a plist, which we need to convert into human readable format with plutil.
The example uses the temporary symlink mapping\_dir to keep our filepaths managable.

```
cd reorg_kobold/external_tools/jtool
ln -s ../../data_from_iextractor/iPhone_4.0_64bit_11.1.2_15B202/machport_to_exec_mapping_dir mapping_dir
./jtool -l mapping_dir/xpcd_cache.dylib
./jtool -e __TEXT.__xpcd_cache mapping_dir/xpcd_cache.dylib
mv ./xpcd_cache.dylib.__TEXT.__xpcd_cache mapping_dir/xpcd_cache.plist
plutil -convert xml1 mapping_dir/xpcd_cache.plist
rm mapping_dir
```

Next we want to extract the machport to executable mapping from the now human readable (xml format) plist.
We use `lazy_cache_plist_parser.py` to build a csv mapping of ports to executables based on the plist.
We assume that all NSXPC services will be provided through Launch Daemon ports.
Therefore, the script will only output results for Launch Daemon entries in the plist.

```
cd reorg_kobold/kobold_scripts
ln -s ../data_from_iextractor/iPhone_4.0_64bit_11.1.2_15B202/machport_to_exec_mapping_dir mapping_dir
./lazy_cache_plist_parser.py mapping_dir/xpcd_cache.plist | sort | uniq > mapping_dir/port_to_exec_mapping.csv
```
