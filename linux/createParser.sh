#!/usr/bin/env bash
source $(dirname "$0")/sweagle.env

##########################################################################
#############
#############   CREATE AND PUBLISH A PARSER FILE IN SWEAGLE
#############
############# Inputs:
############# - Source file to store (this is a javascript Sweagle exporter or validator script
############# - Parser type : EXPORTER or VALIDATOR
#############
############# Output: 0 if no errors, 1 + Details of errors if any
##########################################################################
if [ "$#" -lt "2" ]; then
    echo "********** ERROR: NOT ENOUGH ARGUMENTS SUPPLIED"
    echo "********** YOU SHOULD PROVIDE 1- PARSER FILENAME AND 2- PARSER TYPE"
    echo "********** PARSER TYPE MUST BE EXPORTER OR VALIDATOR"
    exit 1
fi
argSourceFile=$1
argParserType=$2

#filename without path and .js extension for import
filename=$(basename "$argSourceFile" ".js")
fileContent=`cat $argSourceFile`

function apiUrl() {
cat <<EOF
$sweagleURL/api/v1/tenant/metadata-parser?name=$filename&description=$filename&parserType=$argParserType&errorDescriptionDraft=error+in+parser+$filename
EOF
}

echo -e "\n**********"
echo "*** Call Sweagle API to create parser: $filename"
#echo "curl -s -X POST '$(apiUrl)'  --data-urlencode 'scriptDraft=$fileContent' -H '$(apiToken)')"
response=$(curl -s -X POST "$(apiUrl)"  --data-urlencode "scriptDraft=$fileContent" -H "$(apiToken)")

# function to extract a key value from a json result
function jsonValue() {
   key=$1
   num=$2
   awk -F"[,:}]" '{for(i=1;i<=NF;i++){if($i~/\042'$key'\042/){print $(i+1)}}}' | tr -d '"' | sed -n ${num}p
}
parserID=$(echo "$response" | jsonValue "id" 1)

if [[ ! -z $parserID ]]
then
  echo -e "\n**********"
  echo "*** Creation successfull, call Sweagle API to publish parser id: $parserID"
  response=$(curl -s -X POST "$sweagleURL/api/v1/tenant/metadata-parser/$parserID/publish" -H "$(apiToken)")
  echo "Sweagle response:"
  echo "$response"
else
  echo -e "\n**********"
  echo "*** ERROR CREATING PARSER: $filename"
  echo "$response"
  exit 1
fi
