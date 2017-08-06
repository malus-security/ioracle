#!/bin/bash

#this script just calls automatedPostProcessor.sh with different parameters for each iOS version.
#this is where we do the mapping of firmware versions to sandbox data and dynamic analysis data.

#these file paths are hard coded for now, but we can fix this before open sourcing.
#until then, just change them as necessary and treat this script like a config file.
path_to_firm="/media/bigdata/from-ncsu-to-upb/firmware_processing_results_with_dev_after_post_process"
path_to_dynamic="/media/bigdata/dynamic"
path_to_profiles="/media/bigdata/all_profile_facts_7_31_17"

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

##############################################################################
### iOS 6
##############################################################################
this_extension="10.1.1"
this_dynamic="7.1.2"

this_firmware="6.0"
this_profile="iPhone5,1_7.0_11A465/all_profile_facts.pl"
call_post_processor $this_firmware $this_extension $this_dynamic $this_profile 

this_firmware="6.1"
this_profile="iPhone5,1_7.0_11A465/all_profile_facts.pl"
call_post_processor $this_firmware $this_extension $this_dynamic $this_profile 

##############################################################################
### iOS 7
##############################################################################
this_extension="10.1.1"
this_dynamic="7.1.2"

this_firmware="7.0"
this_profile="iPhone5,1_7.0_11A465/all_profile_facts.pl"
call_post_processor $this_firmware $this_extension $this_dynamic $this_profile 

this_firmware="7.1"
this_profile="iPhone5,1_7.1_11D167/all_profile_facts.pl"
call_post_processor $this_firmware $this_extension $this_dynamic $this_profile 

##############################################################################
### iOS 8
##############################################################################
this_extension="10.1.1"
this_dynamic="8.1.2"

this_firmware="8.0"
this_profile="iPhone5,1_8.0_12A365/all_profile_facts.pl"
call_post_processor $this_firmware $this_extension $this_dynamic $this_profile 

this_firmware="8.1"
this_profile="iPhone5,1_8.1_12B411/all_profile_facts.pl"
call_post_processor $this_firmware $this_extension $this_dynamic $this_profile 

this_firmware="8.2"
this_profile="iPhone5,1_8.2_12D508/all_profile_facts.pl"
call_post_processor $this_firmware $this_extension $this_dynamic $this_profile 

this_firmware="8.3"
this_profile="iPhone5,1_8.3_12F70/all_profile_facts.pl"
call_post_processor $this_firmware $this_extension $this_dynamic $this_profile 

this_firmware="8.4"
this_profile="iPhone5,1_8.4_12H143/all_profile_facts.pl"
call_post_processor $this_firmware $this_extension $this_dynamic $this_profile 

##############################################################################
### iOS 9
##############################################################################
this_extension="10.1.1"
this_dynamic="9.3.2"

this_firmware="9.0"
this_profile="iPhone5,1_9.0_13A344/all_profile_facts.pl"
call_post_processor $this_firmware $this_extension $this_dynamic $this_profile 

this_firmware="9.1"
this_profile="iPhone5,1_9.1_13B143/all_profile_facts.pl"
call_post_processor $this_firmware $this_extension $this_dynamic $this_profile 

this_firmware="9.2"
this_profile="iPhone5,1_9.2_13C75/all_profile_facts.pl"
call_post_processor $this_firmware $this_extension $this_dynamic $this_profile 

this_firmware="9.3"
this_profile="iPhone5,1_9.3_13E237/all_profile_facts.pl"
call_post_processor $this_firmware $this_extension $this_dynamic $this_profile 

##############################################################################
### iOS 10
##############################################################################
this_extension="10.1.1"
this_dynamic="10.1.1"

this_firmware="10.0"
this_profile="iPhone_4.0_64bit_10.0.1_14A403/all_profile_facts.pl"
call_post_processor $this_firmware $this_extension $this_dynamic $this_profile 

this_firmware="10.1"
this_profile="iPhone_4.0_64bit_10.1_14B72/all_profile_facts.pl"
call_post_processor $this_firmware $this_extension $this_dynamic $this_profile 

this_firmware="10.2"
this_profile="iPhone_4.0_64bit_10.2_14C92/all_profile_facts.pl"
call_post_processor $this_firmware $this_extension $this_dynamic $this_profile 

this_firmware="10.3"
this_profile="iPhone_4.0_64bit_10.3_14E277/all_profile_facts.pl"
call_post_processor $this_firmware $this_extension $this_dynamic $this_profile 

##############################################################################
### iOS 11
##############################################################################

this_extension="10.1.1"
this_dynamic="10.1.1"

this_firmware="11.0"
this_profile="iPhone_4.0_64bit_10.3_14E277/all_profile_facts.pl"
call_post_processor $this_firmware $this_extension $this_dynamic $this_profile 

