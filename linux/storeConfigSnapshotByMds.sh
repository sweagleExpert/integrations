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
    echo "********** (OPTIONAL) 3- TAG"
    exit 1
fi

argMds=$1
if [ ! -z "$2" ]; then
	argDescription=$2
fi
if [ ! -z "$3" ]; then
	argTag=$3
fi

argLevel="warn"
#uncomment below if you want to store snapshot even if it contains errors
#argLevel="error"

function apiUrl() {
cat <<EOF
$sweagleURL/api/v1/data/include/snapshot/byname?name=$argMds&level=$argLevel
EOF
}

echo -e "\n**********"
echo "*** Call SWEAGLE API to store configuration snapshot for MDS: $argMds with description: $argDescription and tag: $argTag"
# For debugging
#echo "(curl -s -X POST "$(apiUrl)" --data-urlencode "description=$argDescription" -H "$(apiToken)")"
response=$(curl -sw "%{http_code}" "$(apiUrl)" -X POST --data-urlencode "description=$argDescription" --data-urlencode "tag=$argTag" -H "$(apiToken)")

# check curl exit code
rc=$?; if [ "${rc}" -ne "0" ]; then exit ${rc}; fi;

# check http return code, it's ok if 200 (OK) or 201 (created)
get_httpreturn httpcode response; if [[ "${httpcode}" != 20* ]]; then echo $response; exit 1; fi;

echo "*** Snapshot created successfully"
