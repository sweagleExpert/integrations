#!/usr/bin/env bash
source $(dirname "$0")/sweagle.env

##########################################################################
#############
#############   COMPARE 2 SWEAGLE MDS BY NAMES
#############
############# Input: MDS to compare
############# Output: 0 if no errors, 1 + Details of errors if any
##########################################################################

if [ "$#" -lt "2" ]; then
    echo "********** ERROR: NOT ENOUGH ARGUMENTS SUPPLIED"
    echo "********** YOU SHOULD PROVIDE 1-MDS1 AND 2-MDS2"
    exit 1
fi

argMdsFrom=$1
argMdsTo=$2
# Control only if keys are the same in both MDS, ignore values
argKeysOnly=true

function apiUrl() {
# As of now, ignorePath is set to false, because if set to true, it will return a JSON result
# In the future, ignorePath should be set to true as not important for most use cases
cat <<EOF
$sweagleURL/api/v1/data/include/diff?fromName=$argMdsFrom&toName=$argMdsTo&simplified=true&ignorePath=true
EOF
}

echo -e "\n**********"
echo "*** Call Sweagle API to compare configuration from MDS (Old): $argMdsFrom to MDS (New): $argMdsTo"
echo "curl -s -X GET '$(apiUrl)' -H '$(apiToken)'"
response=$(curl -s -X GET "$(apiUrl)" -H "$(apiToken)")


# if only keys are compared, remove all values comparison results
if [ "$argKeysOnly" == "true" ]; then
   echo "********** Compare only keys, ignoring values comparison results"
   # for txt/csv format of response
   #response=`echo "$response" | sed '/"modified",/d'`
   added=$(echo "$response" | jq '.added')
   deleted=$(echo "$response" | jq '.deleted')
   response='{"added":'$added',"deleted":'$deleted'}'
fi

echo "$response" | jq
