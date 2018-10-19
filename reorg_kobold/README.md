# Kobold Reorganization
This directory represents a reorganization of the kobold project which has expanded to include many obsolete scripts.
It should only include scripts the scripts we would include if we were to open source the project.
Experimental efforts should be run in directories labelled "experiment\_" and moved to proper directories when the code is stable.

## Step 1. Extract data for iOS firmware version.
Use iExtractor to extract the file system, sandbox profiles, etc. from the iOS version you want to investigate.
Take the output results of iExtractor and store them in `kobold_reorg/data_from_iextractor/`.
For example:

`mv iExtractor_Results/out/iPhone_4.0_64bit_11.1.2_15B202 kobold_reorg/data_from_iextractor/iPhone_4.0_64bit_11.1.2_15B202`

## Step 2. Compile SBPL Sandbox Profiles into Prolog Facts
Use SandScout to compile the sandbox profiles produced by iExtractor into Prolog facts that can be used by iOracle.
Unfortunately our SandScout automation scripts make a lot of assumptions about directories, so we need to give exact paths. 
For Example:
```
gitHome=\`git rev-parse --show-toplevel\`
cd $gitHome/sandscout
myiOSData=$gitHome/reorg_kobold/data_from_iextractor/iPhone_4.0_64bit_11.1.2_15B202
./processAllProfiles.sh $myiOSData/reversed_profiles $myiOSData/individual_profiles_prolog $myiOSData/consolidated_sb_facts.pl
```

*TODO: we should eventually make sandscout more directory agnostic by adding the gitHome trick to our scripts.*

