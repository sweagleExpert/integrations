#!/usr/bin/env bash
source $(dirname "$0")/sweagle.env

##########################################################################
#############
#############   CHECK SWEAGLE STANDARD CONFIG VALIDATOR STATUS FOR SPECIFIC MDS
#############
############# Input: MDS to check
############# Output: 0 if no errors, 1 + Details of errors if any
##########################################################################

if [ "$#" -lt "1" ]; then
    echo "########## ERROR: NOT ENOUGH ARGUMENTS SUPPLIED"
    echo "########## YOU SHOULD PROVIDE 1-MDS"
    exit 1
fi

argMds=$1
#argControl="warnings"
argControl=errors
argError=error

function apiUrl() {
cat <<EOF
$sweagleURL/api/v1/data/include/validate?name=$argMds&format=json
EOF
}

echo -e "\n##########"
echo "### Call Sweagle API to check configuration status for MDS: $argMds"
response=$(curl -s -k -X GET "$(apiUrl)&forIncoming=true" -H "$(apiToken)")
#echo "Response: " $response

ec=$(echo "$response" | jsonValue $argError)
if [ "$ec" = "NotFoundException" ]; then
  echo "No pending MDS found, relaunch API to get last snapshot result instead"
  response=$(curl -s -k -X GET "$(apiUrl)&forIncoming=false" -H "$(apiToken)")
  echo "SWEAGLE response: $response"
fi

errorFound=$(echo "$response" | jsonValue $argControl)
if [[ $response = "{\"error\":"* ]]; then
    echo -e "\n########## ERROR: Unable to validate MDS: $argMds with standard validators:"
    echo "SWEAGLE response: $response"
    exit 1
elif [ "$errorFound" != 0 ]; then
    echo "########## ERROR: BROKEN configuration data detected for MDS: $argMds for standard validators:"
    echo "SWEAGLE response: $response"
    exit 1
fi

echo "No $argControl found for MDS: "$argMds
