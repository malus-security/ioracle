# iOracle: Automate Evaluation of Access Control Policies and Runtime Context

iOracle is a fairly complex framework that combines the output of multiple static and dynamic analysis tools into Prolog facts which are used along with Prolog rules to answer queries about various qualities of iOS access control and runtime context.

The [iOracle paper](https://dl.acm.org/doi/10.1145/3196494.3196527) (`iOracle: Automated Evaluation of Access Control Policies in iOS`), presented at ASIACCS 2018, details the architecture and implementation of iOracle and our findings.

iOracle is open source software released under the 3-clause BSD license.

Authors:
  * Luke Deshotels, North Carolina State University
  * Răzvan Deaconescu, University POLITEHNICA of Bucharest
  * Costin Carabaș, University POLITEHNICA of Bucharest
  * Iulia Mandă University POLITEHNICA of Bucharest
  * William Enck North Carolina State University
  * Mihai Chiroiu University POLITEHNICA of Bucharest
  * Ninghui Li, Purdue University
  * Ahmad-Reza Sadeghi, Technische Universitat Darmstadt

## Usage

You can skip some of the following steps if you only care about specific queries, but these steps attempt to demonstrate using all available analysis tools to create a comprehensive collection of facts and rules for querying.

### Stage 0: Setup and Prerequisites

Clone iOracle git repo
iOracle repo: https://github.com/malus-security/iOracle
install swipl on macOS with regex package 
iOracle obsolete wiki: https://github.com/malus-security/iOracle/wiki
Use iExtractor to collect firmware, file system, and sbpl profiles
https://github.com/malus-security/iExtractor
Manually extract DDI from Xcode for version being analyzed
https://stackoverflow.com/questions/30736932/xcode-error-could-not-find-developer-disk-image This post shows where to find DDI in recent Xcode file structure.
DDI for several versions can be found in: 
```
/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/DeviceSupport
```
Use terminal or “show package contents” to get into Xcode files
Older or newer versions of Xcode will contain different DDI images for iOS versions. For example, Xcode 9.2 has DDI’s for iOS 8.0 - 11.2
Download older Xcode versions here: https://developer.apple.com/download/more/  

### Stage 1: Combine FS and DDI, then extract metadata and filesystem

Merge iOS firmware and DDI into one file system.
Extract metadata from this combined file system and then archive FS for next analysis stage.
Seems to be: 
https://github.com/malus-security/iOracle/blob/master/automatedDataExtraction/dataExtractorForRootfs\_and\_Dev.sh
TODO: try this for iOS 11.0
TODO: add this and it’s dependencies to a diagram or usage wiki

### Stage 2: Static Analysis using Extracted FS and DDI Archive
Depends on output of Stage 1.
https://github.com/malus-security/iOracle/blob/master/automatedDataExtraction/dataExtractorForExtractedFileSystem.sh

### Stage 3: Dynamic Analysis
This stage requires a jailbroken iOS device
In general we should look for and remove any redundant files. For example, parse\_sandbox\_extensions.py exists in more than one location and one might be obsolete. I think that everything in iOracle/code is also redundant and obsolete. There was also an effort to completely automate iOracle in iOracle/iOracleExecution. I think this is also obsolete, but maybe we could update it. iOracle/prolog is also obsolete. Seems to just contain some irrelevant code for playing with Prolog. The iOracle/sandscout directory seems to be ok for now, but might be better off as a submodule pointing to an independent repo for sandscout.
Run startDynamicAnalysis.sh
https://github.com/malus-security/iOracle/blob/master/automatedDataExtraction/dynamicAnalysisPrototype/startDynamicAnalysis.sh
Take a photo on the iOS device
Make an audio recording on the iOS device
Use iTunes on macOS to backup the iOS device
Run stopDynamicAnalysis.sh
https://github.com/malus-security/iOracle/blob/master/automatedDataExtraction/dynamicAnalysisPrototype/stopDynamicAnalysis.sh

### Stage 4: SandScout
This stage requires the sbpl profiles produced by iExtractor
https://github.com/malus-security/iOracle/tree/master/sandscout
Can process all sbpl profiles for an iOS version or can process multiple versions if they are in the directory structure required by:
https://github.com/malus-security/iOracle/blob/master/sandscout/processAllVersions.sh
(e.g., profiles\_for\_all\_versions/all\_profiles\_for\_a\_version/individual\_profile.sb)

### Stage 5: Post Processing
Depends on all prior steps
automatedPostProcessor.sh can process data produced by prior steps. It resolves symbolic links to absolute paths, finds directory parents, sorts, deduplicates, and consolidates facts into a single .pl file. 
https://github.com/malus-security/iOracle/blob/master/automatedDataExtraction/automatedPostProcessor.sh 
Bulk version can process multiple iOS versions at once, but each version must have an entry in the script. This effectively calls automatedPostProcessor.sh with various arguments.
https://github.com/malus-security/iOracle/blob/master/automatedDataExtraction/bulk\_post\_processor.sh
Output should be a fairly portable file for consolidated Prolog facts (all\_facts.pl)
//Adding Sigil components to iOracle only needs to reach this far. Should I add Sigil as a submodule for iOracle?

### Stage 6: Run Queries
//Need to ask Razvan about this. Seems to all be in iOracle/automatedProcessing

## Map of directories
Here is a description of current and past directories.

### Deleted / Obsolete Directories
automatedAnalysisOfSelfAssignedSandboxes/:
Originally used as a playground for automating sandbox assignment analysis. No longer needed after the functionality was refined and moved into automatedDataExtraction/.

prolog/:
This was a simple playground for practicing simple Prolog queries.
It should not have been added to the project repo.

tools/:
This used to contain tools built by other teams that we use to extract data.
Eventually we moved all these tools into automatedDataExtraction/.

xcode\_projects/:
This seemed to be an attempt to link an xcpode application project as a submodule, but it doesn't seem to point to anything so I deleted it.
We should eventually find these projects and share them somewhere, with or without version control.

obsolete/code/:
The files here seem to be obsolete copies of files that also exist in automatedDataExtraction/. A few of these files are efforts to automate device actions during dynamic analysis. We do not currently use these, but I think they are worth keeping around.

obsolete/iOracleExecution/:
This was an effort to completely automate iOracle, but the crossplatform nature of the framework made such an approach impractical.
These scripts are likely too obsolete to be used, but we could still try to automate more steps.

obsolete/queries/:
These are Prolog queries that should have been consolidated into automatedDataExtraction/scriptsToAutomate/queries.pl.

figure/:
The figures here were obsolete. More current figures exist in the paper's sharelatex repo.

### automatedDataExtraction/:
Scripts and tools that automatically extract data from either iOS firmware or from a jailbroken device.

### automatedProcessing/:
These seem to be automated queries.
Razvan wrote most of these.
It has a detailed README file in it for more information.

### cross\_compile/:
These are programs and make files for working with custom C programs on iOS.
These files should not be needed for normal use of iOracle, but they work well for experimentation and confirming data produced by iOracle.

### documentation/:
This is somewhat obsolete documentation of iOracle.
The documentation for various Prolog facts and rules is helpful, but not all of them are listed.

### idaScripts/:
These are scripts to process IDA files or automate the applications of IDA scripts to multiple executables.
The backtracing IDA script is here, and it is called strider.py.

### obsolete/:
Collection of obsolete files and abandoned projects that I couldn't bring myself to delete.

### query\_testing/:
Framework for test driven development of Prolog rules.
The rules for sandbox and unix policy semantics reside here.

### rules/:
These are rules that provide useful abstractions for supporting high level queries.
Note that sandboxAllowRules.pl and unixAllowRules.pl are symlinks redirecting to query\_testing/.

### sandscout/:
Currently this directory contains the most current version of sandscout, which is used by iOracle to generate facts about sandbox profile rules.

### sigil/:
Sigil is an ivestigation into access control for IPC services.
This involves a lot of reverse engineering ICP services to determine the functionality of each service.
The project also studies entitlements and their role in IPC access control.


