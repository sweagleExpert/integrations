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
    echo "********** ERROR: NOT ENOUGH ARGUMENTS SUPPLIED"
    echo "********** YOU SHOULD PROVIDE 1-MDS"
    exit 1
fi

argMds=$1
#argControl="warnings"
argControl="errors"

function apiUrl() {
cat <<EOF
$sweagleURL/api/v1/data/include/validate?name=$argMds&format=json&forIncoming=true
EOF
}

function jsonValue() {
   key=$1
   num=$2
   awk -F"[,:}]" '{for(i=1;i<=NF;i++){if($i~/\042'$key'\042/){print $(i+1)}}}' | tr -d '"' | sed -n ${num}p
}


echo -e "\n**********"
echo "*** Call Sweagle API to check configuration status for MDS: "$argMds
errorFound=$(curl -s -X GET "$(apiUrl)" -H "$(apiToken)" | jsonValue $argControl 1)
if [ "$errorFound" != 0 ]
then
   echo "********** ERROR: BROKEN configuration data detected, get details of errors and exit"
   responseSweagle=$(curl -s -X GET "$(apiUrl)" -H "$(apiToken)")
   echo "Sweagle response: $responseSweagle"
   exit 1
fi

echo "No $argControl found for MDS: "$argMds
