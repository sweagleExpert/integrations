#!/usr/bin/env bash
source $(dirname "$0")/sweagle.env

##########################################################################
#############
#############   CREATE MDS BY NAME AND PATH
#############
############# Input: name of MDS to create, nodepath of mds
############# Output: 0 if no errors, 1 + Details of errors if any
##########################################################################

if [ "$#" -lt "2" ]; then
    echo "########## ERROR: NOT ENOUGH ARGUMENTS SUPPLIED"
    echo "########## YOU SHOULD PROVIDE 1-NAME OF MDS AND 2-NODE PATH of MDS (node separated by commas)"
    exit 1
fi

mdsName=$1
mdsPath=$2

function createChangeset {
  echo "1- Creating changeset"
  response=$(curl -s -X POST -H "Authorization: bearer $aToken" -H "Accept: application/vnd.siren+json" "$sweagleURL/api/v1/data/changeset" -d "title=Create+new+MDS+$mdsName")
  # Check if any error before continue
  errorFound=$(echo $response | jsonValue "error_description")
  if [[ -z $errorFound ]]; then
    # Extract ChangeSet Id generated for the creation
    csId=$(echo $response | jsonValue "id")
    echo "Created changeset $csId"
  else
    echo -e "\n##########"
    echo "### Error creating Changeset: $errorFound"
    exit 1
  fi
}

function createMDS {
  echo "2- Creating metadataset"
  response=$(curl -s -X POST "$sweagleURL/api/v1/data/include/byPath?changeset=$csId&name=$mdsName&referenceNode=$mdsPath" -H "Authorization: bearer $aToken" -H "Content-Type: application/vnd.siren+json;charset=UTF-8")
  # Check if any error before continue
  errorFound=$(echo $response | jsonValue "error_description")
  if [[ ! -z $errorFound ]]; then
    echo -e "\n##########"
    echo "### Error creating metadata set: $errorFound"
    echo "### Delete changeset before exiting"
    deleteChangeset
    exit 1
  else
    echo "Created metadata set $mdsName"
  fi
}

function approveChangeset
{
  echo "3- Approving changeset $csId"
  response=$(curl -s -X POST -H "Authorization: bearer $aToken" -H "Accept: application/vnd.siren+json" "$sweagleURL/api/v1/data/changeset/$csId/approve")
  # Check if any error before exit
  errorFound=$(echo $response | jsonValue "error_description")
  if [[ -z $errorFound ]]; then
    # Extract ChangeSet Id generated for the creation
    echo " changeset $csId approved"
  else
    echo -e "\n##########"
    echo "### Error approving Changeset: $errorFound"
    exit 1
  fi
}

function deleteChangeset
{
  echo "### Deleting changeset $csId"
  response=$(curl -s -X DELETE -H "Authorization: bearer $aToken" -H "Accept: application/vnd.siren+json" "$sweagleURL/api/v1/data/changeset/$csId")
  echo "### Changeset $csId deleted"
}

createChangeset
createMDS
approveChangeset
