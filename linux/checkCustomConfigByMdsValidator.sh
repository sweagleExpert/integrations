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
# To replace by array of validators in the future
argCustomValidator=$2
validatorResult=true

echo -e "\n**********"
echo "*** Call Sweagle API to check configuration status for MDS: $argMds and VALIDATOR: $argCustomValidator"

function apiUrl() {
cat <<EOF
$sweagleURL/api/v1/tenant/metadata-parser/validate?mds=$argMds&parser=$argCustomValidator&forIncoming=true
EOF
}

# For debugging
#echo "curl -s -X POST '$(apiUrl)' -H '$(apiToken)'"
response=$(curl -s -X POST "$(apiUrl)" -H "$(apiToken)")
echo "Response: " $response
if [[ $response = "{\"error\":"* ]]; then
  echo -e "\n********** ERROR: Unable to validate MDS: $argMds with VALIDATOR: $argCustomValidator  \n"
  exit 1
elif [ "$response" = false ]; then
  echo "********** ERROR: BROKEN configuration data detected for Validator: " $argCustomValidator
  exit 1
fi

echo "No errors found for MDS: "$argMds
