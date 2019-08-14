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
    echo "********** (optional) FORMAT, put format=JSON (or YAML, or XML, or PROPS, or INI, or YAML_SWEAGLE, or JSON_SWEAGLE)"
    echo "********** (optional) FILE OUT, put output=complete_filename_with_path"
    echo "********** (optional) TEMPLATE PARSER, put template=true (default is false)"
    echo "********** (optional) TAG, put tag=complete_tag_name"
    echo "********** (optional) PICTURE, put picture=true (default is false)"
    exit 1
fi

# READ PARAMETERS
argMds=$1
argParser=$2
template="false"
while [[ "$#" > "0" ]]
do
  case $1 in
    (*=*) eval $1;;
  esac
shift
done

function apiUrl() {
  if [ "$template" != "true" ]; then
cat <<EOF
$sweagleURL/api/v1/tenant/metadata-parser/parse?mds=$argMds&parser=$argParser&args=$args&format=$format&tag=$tag&picture=$picture
EOF
  else
cat <<EOF
$sweagleURL/api/v1/tenant/template-parser/replace?mds=$argMds&parser=$argParser&tag=$tag
EOF
  fi
}

echo -e "\n**********"
if [ -z "$tag" ]; then
  echo "*** Call SWEAGLE API to get configuration for MDS: $argMds"
else
  echo "*** Call SWEAGLE API to get configuration for MDS: $argMds and tag: $tag"
fi
# For debugging
#echo "curl -s -X POST '$(apiUrl)' -H '$(apiToken)'"
response=$(curl -sw "%{http_code}" -X POST "$(apiUrl)" -H "$(apiToken)")

# check curl exit code
rc=$?; if [ "${rc}" -ne "0" ]; then exit ${rc}; fi;

# check http return code, it's ok if 200 (OK) or 201 (created)
get_httpreturn httpcode response; if [[ "${httpcode}" != 20* ]]; then echo $response; exit 1; fi;

if [ "$output" != "" ]; then
  echo "*** Store response to file: $output"
  dir=$(dirname "${output}")
  mkdir -p $dir
  echo "$response" > $output
else
  echo -e "*** SWEAGLE response:\n$response"
fi
