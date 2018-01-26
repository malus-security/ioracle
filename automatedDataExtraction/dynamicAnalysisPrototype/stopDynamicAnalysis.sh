#!/bin/bash


if test $# -ne 4; then
	echo "Usage: $0 userOniOSDevice hostOfiOSdevice portForiOSDevice directoryForOutput" 1>&2
	echo "Example: $0 root localhost 2270 directoryForOutput" 1>&2
	exit 1
fi

user="$1"
host="$2"
port="$3"
directoryForOutput="$4"
tempDir="/private/var/mobile/temporaryDirectoryForiOracleExtraction"
outputFileSystem="$4/fileSystem"
outputPrologFacts="$4/prologFacts"

# stop interval_probe.sh
get_pid_interval_probe_cmd=`ps aux | grep interval | grep $2 | awk '{ print $2 }'`
`kill -9 $get_pid_interval_probe_cmd`

# stop filemon_host.sh
get_pid_filemon_cmd=`ps aux | grep filemon | grep $2 | awk '{ print $2 }'`
`kill -9 $get_pid_filemon_cmd`

scp -q -P $port $user@$host:$tempDir/iOracle.out $4/fileSystem/iOracle.out

ssh -p $port $user@$host 'killall filemon'
ssh -p $port $user@$host 'killall sbtool64'

#################################################
#Begin Luke adding procexp automation code here
#################################################
echo "Extracting mach port usage for running processes. Could take about 1 minute."
scp -q -P $port ./get_services/procexp.universal $user@$host:$tempDir/procexp.universal
mkdir "$4/services"
ssh -p $port $user@$host 'bash -s' < ./get_services/bulk_procexp.sh > "$4/services/bulk_procexp.txt"
#################################################
#End Luke adding procexp automation code here
#################################################

ssh -p $port $user@$host "rm -rf $tempDir"

echo "Generating prolog facts"
if [[ -f "$outputFileSystem/pid_uid_gid_comm.out" &&
      -f "$outputFileSystem/raw_sandbox_extensions.out" &&
      -f "$outputFileSystem/iOracle.out" ]];
then
  `./parse_sandbox_extensions.py $outputFileSystem/raw_sandbox_extensions.out $outputFileSystem/pid_uid_gid_comm.out > \
                                 $outputPrologFacts/sandboxExtensions.pl`
  `./fileAccessObservations.py $outputFileSystem/iOracle.out $outputFileSystem/pid_uid_gid_comm.out > \
                               $outputPrologFacts/dynamicFileAccess.pl`
  `./processOwnership.sh $directoryForOutput`
else
  echo "Raw output was not completly generated. Please try again..."
fi

#################################################
#Begin Luke adding procexp parsing code here
#################################################
#It seems that the other parser's are taking $outputFileSystem/pid_uid_gid_comm.out as an input argument.
#I should do the same for procexp output and study how the others map PID's to executable filepaths

./get_services/strip_color.sh $4/services/bulk_procexp.txt > $4/services/bulk_procexp_no_color.txt
`./get_services/parse_services.py $4/services/bulk_procexp_no_color.txt $outputFileSystem/pid_uid_gid_comm.out > \
				$4/services/mach_services.pl`
#################################################
#End Luke adding procexp parsing code here
#################################################


