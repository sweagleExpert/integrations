#!/usr/bin/env bash
source $(dirname "$0")/../sweagle.env
source $(dirname "$0")/../sweagle.lib

##########################################################################
#############
#############   CREATE CDS BY NAME AND PATH
#############
############# Input: name of CDS to create, nodepath of mds
############# Output: 0 if no errors, 1 + Details of errors if any
##########################################################################

if [ "$#" -lt "2" ]; then
    echo "########## ERROR: NOT ENOUGH ARGUMENTS SUPPLIED"
    echo "########## YOU SHOULD PROVIDE 1-NAME OF CDS AND 2-NODE PATH (nodes separated by commas)"
    exit 1
fi

cdsName=$1
cdsPath=$2


echo "1- Creating changeset"
csId=$(createChangeset "Create CDS ${cdsName}")
rc=$?; if [ ${rc} -ne 0 ]; then echo "${csId}"; exit ${rc}; fi;

echo "2- Creating configdataset ${cdsName}"
response=$(createCds ${csId} ${cdsName} ${cdsPath})
rc=$?; if [ ${rc} -ne 0 ]; then echo "${response}"; exit ${rc}; fi;

echo "3- Approving changeset $csId"
response=$(approveChangeset ${csId})
rc=$?; if [ ${rc} -ne 0 ]; then echo "${response}"; exit ${rc}; fi;
echo "Everything's done"
