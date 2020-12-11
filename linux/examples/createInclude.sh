#!/usr/bin/env bash
source $(dirname "$0")/../sweagle.env
source $(dirname "$0")/../sweagle.lib

##########################################################################
#############
#############   CREATE INCLUDE BY BY NODE PATHS
#############
##########################################################################

if [ "$#" -lt "2" ]; then
    echo "########## ERROR: NOT ENOUGH ARGUMENTS SUPPLIED"
    echo "########## YOU SHOULD PROVIDE 1- NODE PATH OF REFERENCE AND 2-NODE PATH OF PARENT (nodes separated by commas)"
    exit 1
fi

approveChangeset=false
referenceNode=$1
parentNode=$2

echo "Creating changeset"
csId=$(createChangeset "Including node ${referenceNode} in node ${parentNode}")
rc=$?; if [ ${rc} -ne 0 ]; then echo "${csId}"; exit ${rc}; fi;

echo "Including node ${referenceNode} in node ${parentNode}"
response=$(createInclude "changeset=${csId}" "referenceNode=${referenceNode}" "parentNode=${parentNode}")
rc=$?; if [ ${rc} -ne 0 ]; then echo "${response}"; exit ${rc}; fi;
#csId=$(echo $response | jsonValue "id")

if [ $approveChangeset = true ]; then
  echo "Approving changeset ${csId}"
  response=$(approveChangeset ${csId})
  rc=$?; if [ ${rc} -ne 0 ]; then echo "${response}"; exit ${rc}; fi;
else
  echo "Changeset is not approved, please check result in changeset:${csId}"
fi

echo "Everything's done"
