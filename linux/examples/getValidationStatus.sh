#!/usr/bin/env bash
source $(dirname "$0")/sweagle.lib

##########################################################################
#############
#############   UPLOAD A DIRECTORY OR FILE TO SWEAGLE IN SPECIFIC PATH
#############
############# Input: 1- Path to upload to, defined by each of the node names separated by ,
############# Input: 2- Config Directory or file to upload
############# Input: 3- Optional: file extension to filter files to read
############# supported extensions are json, xml, yaml, yml, others are considered as property files
############# Output: 0 if no errors, 1 + Details of errors if any
##########################################################################
if [ "$#" -lt "1" ]; then
    echo "########## ERROR: NOT ENOUGH ARGUMENTS SUPPLIED"
    echo "########## YOU MUST PROVIDE 1-CDS"
    echo "########## (OPTIONAL) YOU MAY PROVIDE ALSO 2-FOR INCOMING (false by default)"
    exit 1
fi
argCDS=$1
if [ ! -z "$2" ]; then
  argForIncoming=$2
else
  argForIncoming=false
fi
getValidationStatus cds="$argCDS" forIncoming="$argForIncoming"
