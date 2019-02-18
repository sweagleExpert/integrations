#!/usr/bin/env bash
source $(dirname "$0")/xldeploy.env

##########################################################################
#############
#############   GET CONFIG ITEM (CI) FROM XL-DEPLOY BASED ON ID
#############
############# Inputs: cf. first error below
############# Output: config file if output parameter is provided, screen output if not
##########################################################################
if [ "$#" -lt "1" ]; then
    echo "********** ERROR: NOT ENOUGH ARGUMENTS SUPPLIED"
    echo "********** YOU SHOULD PROVIDE 1-CONFIGURATION ITEM ID"
    echo "********** (optional) FILE OUT, put output=complete_filename_with_path"
    exit 1
fi

argId=$1
while [[ "$#" > "0" ]]
do
  case $1 in
    (*=*) eval $1;;
  esac
shift
done

echo -e "\n**********"
echo "*** Call XL-DEPLOY API to get configuration for ID: " $argId
# For debugging
echo "curl -s -X GET '$xlDeployURL/repository/ci/$argId' --user '$xlDeployUser:$xlDeployPassword'"
response=$(curl -s -X GET "$xlDeployURL/repository/ci/$argId" --user "$xlDeployUser:$xlDeployPassword")
if [ "$output" != "" ]; then
  echo "*** Store response to file: $output"
  dir=$(dirname "${output}")
  mkdir -p $dir
  echo "$response" > $output
else
  echo -e "*** XL-DEPLOY response:\n$response"
fi
