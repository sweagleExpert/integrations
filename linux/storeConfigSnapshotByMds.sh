#!/usr/bin/env bash
source $(dirname "$0")/sweagle.env

##########################################################################
#############
#############   STORE CONFIG INTO SWEAGLE SNAPSHOT FOR SPECIFIC MDS
#############
############# Input: 1- MDS to check, 2- Description of the snapshot (optional)
############# Output: 0 if no errors, 1 + Details of errors if any
##########################################################################
if [ "$#" -lt "1" ]; then
    echo "********** ERROR: NOT ENOUGH ARGUMENTS SUPPLIED"
    echo "********** YOU SHOULD PROVIDE 1- MDS"
    echo "********** (OPTIONAL) 2- DESCRIPTION"
    exit 1
fi

argMds=$1
if [ ! -z "$2" ]; then
	argDescription=$2
fi

argLevel="warn"
#store snapshot even if it contains errors
#argLevel="error"

function apiUrl() {
cat <<EOF
$sweagleURL/api/v1/data/include/snapshot/byname?name=$argMds&level=$argLevel
EOF
}

echo -e "\n**********"
echo "*** Call Sweagle API to store configuration snapshot for MDS: $argMds with description: $argDescription"
# For debugging
#echo "(curl -s -X POST "$(apiUrl)" --data-urlencode "description=$argDescription" -H "$(apiToken)")"
response=$(curl -s -X POST "$(apiUrl)" --data-urlencode "description=$argDescription" -H "$(apiToken)")
echo $response
