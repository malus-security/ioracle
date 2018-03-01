#!/bin/bash

queryFile=$1
temporaryFiles=$2

cat $queryFile $temporaryFiles/mach_services.pl > $temporaryFiles/relevantFacts.pl

query=getServiceNames
./runProlog.sh $query $temporaryFiles > $temporaryFiles/$query.txt
query=serviceProvidersByServiceCount
./runProlog.sh $query $temporaryFiles > $temporaryFiles/$query.txt
query=getSendingServiceNames
./runProlog.sh $query $temporaryFiles > $temporaryFiles/$query.txt
query=getServiceProviders
./runProlog.sh $query $temporaryFiles > $temporaryFiles/$query.txt
query=getRecServiceNames
./runProlog.sh $query $temporaryFiles > $temporaryFiles/$query.txt
query=getLaunchdServiceNames
./runProlog.sh $query $temporaryFiles > $temporaryFiles/$query.txt
query=countReceivingConnections
./runProlog.sh $query $temporaryFiles > $temporaryFiles/$query.txt
