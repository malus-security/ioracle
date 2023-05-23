#!/bin/bash

if test $# -ne 1 -a $# -ne 2; then
	echo "Usage: $0 directoryProducedBydataExtractorForConnectedDeviceScript <num_step>" 1>&2
	echo "Example: $0 iPod5_iOS812_12B440 5" 1>&2
    echo ""
    echo "Steps"
    echo "  1. "
	exit 1
fi

step=""
if test $# -eq 2; then
    if test $2 -ne -3; then
        if test $2 -lt 1 -o $2 -gt 19; then
            echo "Step number should be between 1 and 19"
            echo "To exclude step 3, use -3 flag"
        fi
    fi
    step="$2"
fi

extractionDirectory="$1"
temporaryFiles=$extractionDirectory/temporaryFiles

# Allow easy output to stderr.
echoerr() { echo "$@" 1>&2; }

step_1_create_directories()
{
    echo "temp is $temporaryFiles"
    rm -rf $temporaryFiles
    mkdir $temporaryFiles
    mkdir $extractionDirectory/prologFacts > /dev/null 2>&1
    mkdir $extractionDirectory/ida_base_analysis > /dev/null 2>&1
}

step_2_unpack()
{
    #I think unpacking the extracted file system should be done in this script instead of the script for a connected device
    #make the new file system owned by the current user to avoid needing sudo all the time.
    #We can get the unix permissions by extracting metadata from the device, so its ok if we lose them locally.

    echo 'extracting archived file system'
    echoerr 'extracting archived file system'
    #TODO I need to put this line back in after testing
    time sudo tar -xzf $extractionDirectory/fileSystem.tar.gz -C $extractionDirectory/fileSystem
    sudo chown -R $USER $extractionDirectory
    chmod -R 777 $extractionDirectory
}


step_3_get_file_types()
{
    echo 'getting file types'
    echoerr 'getting file types'
    # Get file types from the file system extracted to the local system.
    time ./scriptsToAutomate/fileTypeExtractor.sh $extractionDirectory/fileSystem > $extractionDirectory/prologFacts/unsanitized_file_types.pl
    time ./scriptsToAutomate/sanitizeFilePaths.py $extractionDirectory/prologFacts/unsanitized_file_types.pl > $extractionDirectory/prologFacts/file_types.pl
}

step_4_get_user_data()
{
    echo 'getting user data'
    echoerr 'getting user data'
    # Extract data about users from etc.
    time ./scriptsToAutomate/userFactExtractor.sh $extractionDirectory/fileSystem > $extractionDirectory/prologFacts/users.pl
}

step_5_get_group_data()
{
    echo 'getting group data'
    echoerr 'getting group data'
    # Extract data about groups from etc.
    time ./scriptsToAutomate/groupFactExtractor.sh $extractionDirectory/fileSystem > $extractionDirectory/prologFacts/groups.pl
}

step_6_get_paths_execs()
{
    echo 'getting file paths of Mach-O executables'
    echoerr 'getting file paths of Mach-O executables'
    cat $extractionDirectory/prologFacts/file_types.pl ./scriptsToAutomate/queries.pl > $temporaryFiles/relevantFacts.pl
    time ./scriptsToAutomate/runProlog.sh justPaths $temporaryFiles > $temporaryFiles/filePaths.out
    rm $temporaryFiles/relevantFacts.pl
}

step_7_get_signatures_apple_execs()
{
    echo 'getting signatures of Apple-Signed Mach-O executables'
    echoerr 'getting signatures of Apple-Signed Mach-O executables'
    # Note that because of file path sanitization, if a mach-o executable's path was sanitized, the script won't be able to find the file.
    # I don't expect this to be a problem in practice, but we can keep an eye on it to see if it every happens. It should throw an error if it does.
    time ./scriptsToAutomate/signatureExtractor.sh $extractionDirectory/fileSystem < $temporaryFiles/filePaths.out > $extractionDirectory/prologFacts/apple_executable_files_signatures.pl
    # cat $extractionDirectory/prologFacts/apple_executable_files_signatures.pl
}

step_8_get_paths_apple_execs()
{
    echo 'getting file paths for Apple-Signed Mach-O executables'
    echoerr 'getting file paths for Apple-Signed Mach-O executables'
    # Generate a list of file paths to Apple-signed mach-o executable files.
    cat $extractionDirectory/prologFacts/apple_executable_files_signatures.pl ./scriptsToAutomate/queries.pl > $temporaryFiles/relevantFacts.pl
    time ./scriptsToAutomate/runProlog.sh justApplePaths $temporaryFiles > $temporaryFiles/applefilePaths.out
    #cat $temporaryFiles/applefilePaths.out
    rm $temporaryFiles/relevantFacts.pl
}

step_9_get_entitlements_apple_execs()
{
    echo 'getting entitlements for Apple-Signed Mach-O executables'
    echoerr 'getting entitlements for Apple-Signed Mach-O executables'
    # Extract entitlements from programs listed in the input.
    time ./scriptsToAutomate/entitlementExtractor.sh $extractionDirectory/fileSystem < $temporaryFiles/applefilePaths.out > $extractionDirectory/prologFacts/apple_executable_files_entitlements.pl
    #cat $extractionDirectory/prologFacts/apple_executable_files_entitlements.pl
}

step_10_get_strings_apple_execs()
{
    echo 'getting strings for Apple-Signed Mach-O executables'
    echoerr 'getting strings for Apple-Signed Mach-O executables'
    time ./scriptsToAutomate/stringExtractor.sh $extractionDirectory/fileSystem < $temporaryFiles/applefilePaths.out > $extractionDirectory/prologFacts/apple_executable_files_strings.pl
    #cat $extractionDirectory/prologFacts/apple_executable_files_strings.pl
}

step_11_get_symbols_apple_execs()
{
    echo 'getting symbols for Apple-Signed Mach-O executables'
    echoerr 'getting symbols for Apple-Signed Mach-O executables'
    time ./scriptsToAutomate/symbolExtractor.sh $extractionDirectory/fileSystem < $temporaryFiles/applefilePaths.out > $extractionDirectory/prologFacts/apple_executable_files_symbols.pl
    #cat $extractionDirectory/prologFacts/apple_executable_files_symbols.pl
}

step_12_get_sandbox_profiles()
{
    echo 'getting sandbox profile assignments based on entitlements and file paths'
    echoerr 'getting sandbox profile assignments based on entitlements and file paths'
    cat $extractionDirectory/prologFacts/apple_executable_files_signatures.pl $extractionDirectory/prologFacts/apple_executable_files_entitlements.pl ./scriptsToAutomate/queries.pl > $temporaryFiles/relevantFacts.pl
    time ./scriptsToAutomate/runProlog.sh getProfilesFromEntitlementsAndPaths $temporaryFiles > $temporaryFiles/profileAssignmentFromEntAndPath.pl
    # cat $temporaryFiles/profileAssignmentFromEntAndPath.pl
    rm $temporaryFiles/relevantFacts.pl
}

step_13_get_paths_self_assigned_sandbox()
{
    echo 'getting file paths to processes that assign sandboxes to themselves.'
    echoerr 'getting file paths to processes that assign sandboxes to themselves.'
    cat $extractionDirectory/prologFacts/apple_executable_files_symbols.pl ./scriptsToAutomate/queries.pl > $temporaryFiles/relevantFacts.pl
    time ./scriptsToAutomate/runProlog.sh getSelfAssigningProcessesWithSymbols $temporaryFiles > $temporaryFiles/pathsToSelfAssigners.out
    # cat $temporaryFiles/pathsToSelfAssigners.out
    rm $temporaryFiles/relevantFacts.pl
}

step_14_run_ida_batch()
{
    echo 'running batch ida analysis on self assigning executables'
    echoerr 'running batch ida analysis on self assigning executables'
    #TODO Need to mention that I fixed an important typo here where there should have been a / after $extractionDirectory/fileSystem
    time ./scriptsToAutomate/idaBatchAnalysis.sh $extractionDirectory/fileSystem/ $temporaryFiles/pathsToSelfAssigners.out $temporaryFiles/
}

step_15_run_id_backtrace()
{
    echo 'running backtracing ida scripts on self assigning executables'
    echoerr 'running backtracing ida scripts on self assigning executables'
    time ./scriptsToAutomate/mapIdaScriptToTargets.sh $temporaryFiles/hashedPathToFilePathMapping.csv ./scriptsToAutomate/strider.py $temporaryFiles/ $temporaryFiles/sandboxInit.out ./configurationFiles/sandboxInit.config
    time ./scriptsToAutomate/mapIdaScriptToTargets.sh $temporaryFiles/hashedPathToFilePathMapping.csv ./scriptsToAutomate/strider.py $temporaryFiles/ $temporaryFiles/sandboxInitWithParameters.out ./configurationFiles/sandboxInitWithParameters.config
    time ./scriptsToAutomate/mapIdaScriptToTargets.sh $temporaryFiles/hashedPathToFilePathMapping.csv ./scriptsToAutomate/strider.py $temporaryFiles/ $temporaryFiles/applyContainer.out ./configurationFiles/applyContainer.config
}

step_16_consolidate_ida()
{
    echo 'consolidating and parsing output of IDA analysis on sandbox self assigners with assignments based on entitlements and file paths.'
    echoerr 'consolidating and parsing output of IDA analysis on sandbox self assigners with assignments based on entitlements and file paths.'
    cat $temporaryFiles/applyContainer.out $temporaryFiles/sandboxInit.out $temporaryFiles/sandboxInitWithParameters.out > $temporaryFiles/selfApplySandbox.pl
    cat $temporaryFiles/selfApplySandbox.pl ./scriptsToAutomate/queries.pl > $temporaryFiles/relevantFacts.pl
    time ./scriptsToAutomate/runProlog.sh parseSelfAppliedProfiles $temporaryFiles > $temporaryFiles/parsedFilteredSelfAppliers.pl
    rm $temporaryFiles/relevantFacts.pl

    cat $temporaryFiles/profileAssignmentFromEntAndPath.pl $temporaryFiles/parsedFilteredSelfAppliers.pl > $extractionDirectory/prologFacts/processToProfileMapping.pl
}

step_17_get_vnode_types()
{
    echo 'getting vnode types. This should probably move to the connected device script later.'
    cat $extractionDirectory/prologFacts/file_metadata.pl ./scriptsToAutomate/queries.pl > $temporaryFiles/relevantFacts.pl
    time ./scriptsToAutomate/runProlog.sh getVnodeTypes $temporaryFiles > $extractionDirectory/prologFacts/vnodeTypes.pl
    rm $temporaryFiles/relevantFacts.pl
}

step_18_get_direct_file_access_caller()
{
    # Backtracer analysis for functions known to be used in jailbreak gadgets (e.g., chown and chmod).
    echo 'getting file paths to processes that use chmod or chown.'
    echoerr 'getting file paths to processes that use chmod or chown.'
    cat $extractionDirectory/prologFacts/apple_executable_files_symbols.pl ./scriptsToAutomate/queries.pl > $temporaryFiles/relevantFacts.pl
    time ./scriptsToAutomate/runProlog.sh getDirectFileAccessCallersWithSymbols $temporaryFiles > $extractionDirectory/ida_base_analysis/pathsToDirectFileAccessCallers.out
    rm $temporaryFiles/relevantFacts.pl
}

step_19_run_ida_batch_direct_file_access()
{
    echoerr 'running batch ida analysis on direct file access call executables'
    time ./scriptsToAutomate/idaBatchAnalysis.sh $extractionDirectory/fileSystem/ $extractionDirectory/ida_base_analysis/pathsToDirectFileAccessCallers.out $extractionDirectory/ida_base_analysis/

    time ./scriptsToAutomate/mapIdaScriptToTargets.sh $extractionDirectory/ida_base_analysis/hashedPathToFilePathMapping.csv ./scriptsToAutomate/strider.py  $extractionDirectory/ida_base_analysis/ $extractionDirectory/prologFacts/chown_backtrace.pl ./configurationFiles/chown.config
    time ./scriptsToAutomate/mapIdaScriptToTargets.sh $extractionDirectory/ida_base_analysis/hashedPathToFilePathMapping.csv ./scriptsToAutomate/strider.py  $extractionDirectory/ida_base_analysis/ $extractionDirectory/prologFacts/chmod_backtrace.pl ./configurationFiles/chmod.config
}

#Now that we have a way to collect sandbox extensions, we should not need this anymore.
#It was a way to run queries assuming that no process had any sandbox extensions.
#echo "sandbox_extension( _, _) :- fail." > $extractionDirectory/prologFacts/sandboxExtensionPlaceHolders.pl

#the curly brackets have bundled the commands so the error output will be funneled into one file

if test -z "$step"; then
    step_1_create_directories
    step_2_unpack
    step_3_get_file_types
    step_4_get_user_data
    step_5_get_group_data
    step_6_get_paths_execs
    step_7_get_signatures_apple_execs
    step_8_get_paths_apple_execs
    step_9_get_entitlements_apple_execs
    step_10_get_strings_apple_execs
    step_11_get_symbols_apple_execs
    step_12_get_sandbox_profiles
    step_13_get_paths_self_assigned_sandbox
    step_14_run_ida_batch
    step_15_run_id_backtrace
    step_16_consolidate_ida
    step_17_get_vnode_types
    step_18_get_direct_file_access_caller
    step_19_run_ida_batch_direct_file_access
elif test $2 -eq -3; then
    step_1_create_directories
    step_2_unpack
    echo ""
    echo "step 3 excluded (get file types), unsanitized_file_types.pl might be populated"
    echo ""
    step_4_get_user_data
    step_5_get_group_data
    step_6_get_paths_execs
    step_7_get_signatures_apple_execs
    step_8_get_paths_apple_execs
    step_9_get_entitlements_apple_execs
    step_10_get_strings_apple_execs
    step_11_get_symbols_apple_execs
    step_12_get_sandbox_profiles
    step_13_get_paths_self_assigned_sandbox
    step_14_run_ida_batch
    step_15_run_id_backtrace
    step_16_consolidate_ida
    step_17_get_vnode_types
    step_18_get_direct_file_access_caller
    step_19_run_ida_batch_direct_file_access
else
    case "$step" in

        "1")
            step_1_create_directories
            ;;
        "2")
            step_2_unpack
            ;;
        "3")
            step_3_get_file_types
            ;;
        "4")
            step_4_get_user_data
            ;;
        "5")
            step_5_get_group_data
            ;;
        "6")
            step_6_get_paths_execs
            ;;
        "7")
            step_7_get_signatures_apple_execs
            ;;
        "8")
            step_8_get_paths_apple_execs
            ;;
        "9")
            step_9_get_entitlements_apple_execs
            ;;
        "10")
            step_10_get_strings_apple_execs
            ;;
        "11")
            step_11_get_symbols_apple_execs
            ;;
        "12")
            step_12_get_sandbox_profiles
            ;;
        "13")
            step_13_get_paths_self_assigned_sandbox
            ;;
        "14")
            step_14_run_ida_batch
            ;;
        "15")
            step_15_run_id_backtrace
            ;;
        "16")
            step_16_consolidate_ida
            ;;
        "17")
            step_17_get_vnode_types
            ;;
        "18")
            step_18_get_direct_file_access_caller
            ;;
        "19")
            step_19_run_ida_batch_direct_file_access
            ;;
        *)
            ;;
    esac
fi
