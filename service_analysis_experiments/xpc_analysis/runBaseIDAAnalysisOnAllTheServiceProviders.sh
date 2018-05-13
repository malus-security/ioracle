#!/bin/bash

#TODO use idaBatchAnalysis to process the following list of executables and store them somewhere reasonable like the bigdata partition.
cat cache_data/xpcd_cache.pl | sed "s/.*executablePath('//" | sed "s/').*//" | sort | uniq > temp/serviceProviderExecutables.out

./idaBatchAnalysis.sh /media/bigdata/from-ncsu-to-upb/firmware_processing_results_with_dev_after_post_process/10.1/fileSystem ./temp/serviceProviderExecutables.out /media/bigdata/from-ncsu-to-upb/firmware_processing_results_with_dev_after_post_process/10.1/serviceProvider_analysis


