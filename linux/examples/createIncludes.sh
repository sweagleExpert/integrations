#!/usr/bin/env bash
source $(dirname "$0")/../sweagle.env
source $(dirname "$0")/../sweagle.lib

##########################################################################
#############
#############   CREATE INCLUDES BY NODE PATHS
#############
############# Inputs: 2 arrays of node path to include and where to include them
##########################################################################

approveChangeset=false
parentNodes=("mars,CR,env1" "mars,CR,env2")
referenceNodes=("mars,env-template" "mars,env-template")

echo "Creating changeset"
csId=$(createChangeset "Create multiple includes")
rc=$?; if [ ${rc} -ne 0 ]; then echo "${csId}"; exit ${rc}; fi;

echo "Creating multiple includes"
response=$(createMultipleIncludes changeset=${csId} referenceNodes="${referenceNodes[@]}" parentNodes="${parentNodes}")
rc=$?; if [ ${rc} -ne 0 ]; then echo "${response}"; exit ${rc}; fi;
#echo $response

if [ $approveChangeset = true ]; then
  echo "Approving changeset ${csId}"
  response=$(approveChangeset ${csId})
  rc=$?; if [ ${rc} -ne 0 ]; then echo "${response}"; exit ${rc}; fi;
else
  echo "Changeset is not approved, please check result in changeset:${csId}"
fi

echo "Everything's done"
