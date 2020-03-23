#!/usr/bin/env bash
source $(dirname "$0")/sweagle.env
source $(dirname "$0")/sweagle-admin.lib

echo "### START TEST"
#response=$(getParsers "status=PUBLISHED" "parserType=EXPORTER")
#echo "$response"
response=$(getParserIdFromName "parserName=passwordChecker" "parserType=VALIDATOR" "status=PUBLISHED")
parserId=$response
echo "parserId=$parserId"

#response=$(getConfigDataSets)
#echo "$response"
response=$(getConfigDataSetIdFromName "cdsName=XXX" "forIncoming=true")
cdsId=$response
echo "cdsId=$cdsId"

response=$(assignParserToCds parserId=$parserId cdsId=$cdsId)
#response=$(assignParserToCdsByName parserName=passwordChecker cdsName=cnp)
echo $response

echo "### END TEST"
