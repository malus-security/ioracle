#!/bin/bash

#TODO allow commandline arguments for specifying the location of various directories
#location of prolog query files
#location of iOS file system
#location of ida scripts
#location for results of IDA analysis

#This script assumes the following files are present with the following fact conventions:
#stringsFromPrograms.pl
#	processString(filePath("/bin/df"),stringFromProgram("__PAGEZERO")).
#systemEntitlementFacts.pl
#	process(filePath("/bin/launchctl"),entitlement(key("com.apple.private.xpc.launchd.userspace-reboot"),value(bool("true")))).
#appleProgramSignatures.pl
#	processSignature(filePath("/bin/df"),identifier("com.apple.df")).

##########################################################################################
#find simple profile assignments and get paths for self assigners
##########################################################################################

./runProlog.sh getProfilesFromEntitlementsAndPaths > profileAssignmentFromEntAndPath.pl
./runProlog.sh getSelfAssigningProcesses > pathsOfSelfAssigners.out

##########################################################################################
#Basic IDA Analysis
#This phase is redundant if all executables were already analyzed.
##########################################################################################

#I am assuming the program files to be analyzed are in the following directory or a symlink to the directory with the following filepath:
#./phoneFileSystem/
#Example:
#ladeshot@cascades:~/iOracle/automatedSandboxAssignments$ ls -l phoneFileSystem
#lrwxrwxrwx 1 ladeshot ladeshot 31 Feb 10 16:44 phoneFileSystem -> /home/ladeshot/FileSystem9.0.2/

rm -rf ./resultsOfAnalyzingSelfAppliers
mkdir ./resultsOfAnalyzingSelfAppliers
../idaScripts/idaBatchAnalysis.sh phoneFileSystem pathsToSelfAssigners.out resultsOfAnalyzingSelfAppliers/

##########################################################################################
#Run strider script on the ida database files
#Strider uses a config file, so we made one for each function to look for
##########################################################################################

mkdir striderOuput
../idaScripts/mapIdaScriptToTargets.sh resultsOfAnalyzingSelfAppliers/hashedPathToFilePathMapping.csv ../idaScripts/strider.py resultsOfAnalyzingSelfAppliers/ ./striderOuput/sandboxInit.out ../idaScripts/sandboxInit.config

../idaScripts/mapIdaScriptToTargets.sh resultsOfAnalyzingSelfAppliers/hashedPathToFilePathMapping.csv ../idaScripts/strider.py resultsOfAnalyzingSelfAppliers/ ./striderOuput/applyContainer.out ../idaScripts/applyContainer.config

##########################################################################################
#Merge results of strider, change format, and remove bad and redundant facts.
#Merge with other profile assignment facts.
##########################################################################################

cat ./striderOuput/applyContainer.out striderOuput/sandboxInit.out > ./selfApplySandbox.pl

./runProlog.sh parseSelfAppliedProfiles > ./parsedFilteredSelfAppliers.pl

cat profileAssignmentFromEntAndPath.pl parsedFilteredSelfAppliers.pl > processToProfileMapping.pl


