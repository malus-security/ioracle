#!/bin/bash

#this script just calls automatedPostProcessor.sh with different parameters for each iOS version.
#this is where we do the mapping of firmware versions to sandbox data and dynamic analysis data.

#these file paths are hard coded for now, but we can fix this before open sourcing.
#until then, just change them as necessary and treat this script like a config file.
path_to_firm="/media/bigdata/temporary_firmware"
path_to_dynamic="/media/bigdata/dynamic"
path_to_profiles="/media/bigdata/temporary_profiles"

function call_post_processor {
  firmware=$path_to_firm/$1
  extension=$path_to_dynamic/$2
  dynamic=$path_to_dynamic/$3
  profile=$path_to_profiles/$4
  echo About to process $firmware
  time ./automatedPostProcessor.sh $firmware $extension $dynamic $profile
  sleep 1
  echo Done processing $firmware
}

this_firmware="10.0"
this_extension="10.1.1"
this_dynamic="10.1.1"
this_profile="iPhone5,1_9.3_13E237/all_profile_facts.pl"
call_post_processor $this_firmware $this_extension $this_dynamic $this_profile 

this_firmware="10.2"
this_extension="10.1.1"
this_dynamic="10.1.1"
this_profile="iPhone5,1_9.3_13E237/all_profile_facts.pl"
call_post_processor $this_firmware $this_extension $this_dynamic $this_profile 

