#!/usr/bin/env bash
source $(dirname "$0")/sweagle.env

##########################################################################
#############
#############   GET CONFIG DATA FROM SWEAGLE FOR SPECIFIC MDS AND PARSER
#############
############# Inputs: cf. first error below
############# Output: 0 if no errors, 1 + Details of errors if any
##########################################################################
if [ "$#" -lt "2" ]; then
    echo "********** ERROR: NOT ENOUGH ARGUMENTS SUPPLIED"
    echo "********** YOU SHOULD PROVIDE 1- MDS AND 2- PARSER"
    echo "********** (optional) PARSER ARGUMENTS, put args=all_values_separated_by_comma"
    echo "********** (optional) FORMAT, put format=JSON (or YAML, or XML, or PROPS)"
    echo "********** (optional) FILE OUT, put output=complete_filename_with_path"
    exit 1
fi

# READ PARAMETERS
argMds=$1
argParser=$2
while [[ "$#" > "0" ]]
do
  case $1 in
    (*=*) eval $1;;
  esac
shift
done

function apiUrl() {
cat <<EOF
$sweagleURL/api/v1/tenant/metadata-parser/parse?mds=$argMds&parser=$argParser&args=$args&format=$format
EOF
}

echo -e "\n**********"
echo "*** Call Sweagle API to get configuration for MDS: " $argMds
# For debugging
echo "curl -s -X POST ''$(apiUrl)' -H '$(apiToken)'"
responseSweagle=$(curl -s -X POST "$(apiUrl)" -H "$(apiToken)")
if [ "$output" != "" ]; then
  echo "*** Store response to file: $output"
  dir=$(dirname "${output}")
  mkdir -p $dir
  echo "$responseSweagle" >> $output
else
  echo -e "*** Sweagle response:\n$responseSweagle"
fi
