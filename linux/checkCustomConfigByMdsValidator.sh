#!/usr/bin/env bash
source $(dirname "$0")/sweagle.env

##########################################################################
#############
#############   CHECK CONFIG STATUS FROM SWEAGLE FOR SPECIFIC MDS & VALIDATOR
#############
############# Input: MDS to check, VALIDATOR to use
############# Output: 0 if no errors, 1 if errors
##########################################################################

if [ "$#" -lt "2" ]; then
    echo "********** ERROR: NOT ENOUGH ARGUMENTS SUPPLIED"
    echo "********** YOU SHOULD PROVIDE 1-MDS AND 2-VALIDATOR"
    exit 1
fi
argMds=$1
argCustomValidator=$2
argControl=result
argError=error

echo -e "\n**********"
echo "*** Call Sweagle API to check configuration status for MDS: $argMds and VALIDATOR: $argCustomValidator"

function apiUrl() {
cat <<EOF
$sweagleURL/api/v1/tenant/metadata-parser/validate?mds=$argMds&parser=$argCustomValidator
EOF
}

# For debugging
#echo "curl -s -X POST '$(apiUrl)&forIncoming=true' -H '$(apiToken)'"
# First, check result for pending MDS
response=$(curl -s -X POST "$(apiUrl)&forIncoming=true" -H "$(apiToken)")
echo "Response: " $response

ec=$(echo "$response" | jsonValue $argError)
if [ "$ec" = "NotFoundException" ]; then
  echo "No pending MDS found, relaunch API to get last snapshot result instead"
  response=$(curl -s -X POST "$(apiUrl)&forIncoming=false" -H "$(apiToken)")
  echo "Response: " $response
fi

rc=$(echo "$response" | jsonValue $argControl)
if [[ $response = "{\"error\":"* ]]; then
    echo -e "\n********** ERROR: Unable to validate MDS: $argMds with validator: $argCustomValidator \n"
    exit 1
elif [ "$rc" = false ]; then
    echo "********** ERROR: BROKEN configuration data detected for validator: " $argCustomValidator
    exit 1
fi

echo "No errors found for MDS: "$argMds
