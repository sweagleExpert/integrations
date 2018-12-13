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
parserId=""

#filename without path and .js extension for import
filename=$(basename "$argSourceFile" ".js")
fileContent=`cat $argSourceFile`

#get description from firstline of file
read -r firstline<$argSourceFile
if [[ $firstline == "// description:"* ]]; then
  description=$(echo $firstline| cut -d':' -f 2)
else
  description="$filename"
fi

# Put json parsers list in variable parsersList
function getParsers {
  echo "*** Get parsers list"
  response=$(curl -s -X GET "$sweagleURL/api/v1/tenant/metadata-parser" -H "Authorization: bearer $aToken" -H "Accept: application/vnd.siren+json")
  # Check if any error before continue
  errorFound=$(echo $response | jsonValue "error_description")
  if [[ -z $errorFound ]]; then
    parsersList="$response"
  else
    echo -e "\n**********"
    echo "*** Error getting parser list: $errorFound"
    exit 1
  fi
}

#Return Parser Id from Parsers list identified by its name
function getParserIdFromName {
parserName="$1" jsonValue="$2" python - <<EOF_PYTHON
#!/usr/bin/python
import json
import os
parserName = os.environ['parserName']
#print("*** Use python to get Id for Parser "+parserName)
json1 = json.loads(os.environ['jsonValue'])
for item in json1["entities"]:
  if item["properties"]["name"] == parserName:
      print item["properties"]["id"]
EOF_PYTHON
}

# Create parser from file and put new created Id in variable parserId
function createParser {
  local argName=$1
  local argDescription=$2
  local argScript=$3
  echo "*** Create parser with name: $argName"
  response=$(curl -s -X POST "$sweagleURL/api/v1/tenant/metadata-parser?name=$filename&parserType=$argParserType&errorDescriptionDraft=error+in+parser+$filename" --data-urlencode "description=$argDescription" --data-urlencode "scriptDraft=$argScript" -H "Authorization: bearer $aToken" -H "Accept: application/vnd.siren+json")
  # Check if any error before continue
  errorFound=$(echo $response | jsonValue "error_description")
  if [[ -z $errorFound ]]; then
    parserId=$(echo "$response" | jsonValue "id")
    echo "*** Created parser with id: $parserId"
  else
    echo -e "\n**********"
    echo "*** Error creating parser: $errorFound"
  fi
}

# Update parser from Id + script
function updateParser {
  local argId=$1
  local argDescription=$2
  local argScript=$3
  echo "*** Update parser $argId"
  # to debug
  #echo "curl -s -X POST '$sweagleURL/api/v1/tenant/metadata-parser/$argId' --data-urlencode 'description=$argDescription' --data-urlencode 'scriptDraft=$argScript' -H 'Authorization: bearer $aToken' -H 'Accept: application/vnd.siren+json'"
  response=$(curl -s -X POST "$sweagleURL/api/v1/tenant/metadata-parser/$argId" --data-urlencode "description=$argDescription" --data-urlencode "scriptDraft=$argScript" -H "Authorization: bearer $aToken" -H "Accept: application/vnd.siren+json")
  # Check if any error before continue
  errorFound=$(echo $response | jsonValue "error_description")
  if [[ -z $errorFound ]]; then
    echo "*** Updated parser with id: $argId"
  else
    echo -e "\n**********"
    echo "*** Error updating parser: $errorFound"
  fi
}

function publishParser {
  local argId=$1
  echo "*** Publish parser with id: $argId"
  response=$(curl -s -X POST "$sweagleURL/api/v1/tenant/metadata-parser/$argId/publish" -H "Authorization: bearer $aToken" -H "Accept: application/vnd.siren+json" )
  errorFound=$(echo $response | jsonValue "error_description")
  if [[ -z $errorFound ]]; then
    echo "*** Published parser $argId"
  else
    echo -e "\n**********"
    echo "*** Error publishing parser: $errorFound"
  fi
}

function getNextParserId {
  echo "*** Get parser list"
  response=$(curl -s -X GET -H "Authorization: bearer $aToken" -H "Accept: application/vnd.siren+json" "$sweagleURL/api/v1/tenant/metadata-parser")
  # Check if any error before continue
  errorFound=$(echo $response | jsonValue "error_description")
  if [[ -z $errorFound ]]; then
    # Extract next Parser Id from list
    parserId=$(echo $response | jsonValue "id")
    echo "Next parser Id is $parserId"
  else
    echo -e "\n**********"
    echo "*** Error getting parser list: $errorFound"
    exit 1
  fi
}

function deleteParser {
  local argId=$1
  echo "*** Deleting parser $argId"
  response=$(curl -s -X DELETE "$sweagleURL/api/v1/tenant/metadata-parser/$argId" -H "Authorization: bearer $aToken" -H "Accept: application/vnd.siren+json")
  # Check if any error before continue
  errorFound=$(echo $response | jsonValue "error_description")
  if [[ -z $errorFound ]]; then
    echo "*** Parser $argId deleted"
  else
    echo -e "\n**********"
    echo "*** Error deleting parser: $errorFound"
    exit 1
  fi
}


echo -e "\n**********"
createParser "$filename" "$description" "$fileContent"
# Check if error returned because parser already exists
if [[ $response == *"already exists"* ]]; then
  echo "It's already there! Updating it"
  getParsers
  parserId=$(getParserIdFromName "$filename" "$parsersList")
  updateParser $parserId "$description" "$fileContent"
fi
if [[ ! -z $parserId ]]; then
  publishParser $parserId
else
  echo -e "\n**********"
  echo "*** ERROR CREATING PARSER: $filename"
  exit 1
fi
