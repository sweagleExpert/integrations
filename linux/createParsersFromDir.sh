#!/usr/bin/env bash

##########################################################################
#############
#############   UPLOAD A DIRECTORY OR FILE OF PARSERS TO SWEAGLE
#############
############# Input: 1- Config Directory or file to upload
############# Input: 2- Parser type : EXPORTER or VALIDATOR
#############
############# Output: 0 if no errors, 1 + Details of errors if any
##########################################################################
if [ "$#" -lt "2" ]; then
    echo "********** ERROR: NOT ENOUGH ARGUMENTS SUPPLIED"
    echo "********** YOU SHOULD PROVIDE 1- PARSER FILENAME OR DIRECTORY AND 2- PARSER TYPE"
    echo "********** PARSER TYPE MUST BE EXPORTER OR VALIDATOR"
    exit 1
fi
argSourceDir=$1
argParserType=$2

sweagleScriptDir="$PWD"/$(dirname "$0")

if [[ -f "$argSourceDir" ]] ; then
  # the arg is a file, call the upload script only once
  $sweagleScriptDir/createParserFromFile.sh "$argSourceDir" "$argParserType"
elif [[ -d "$argSourceDir" ]] ; then
  # The arg is a directory, call the api for all files
  cd "$argSourceDir"
  # Execute only for javascript files in the target directory
  for file in *.js; do
    $sweagleScriptDir/createParserFromFile.sh "$file" "$argParserType"
  done
else
    echo "********** ERROR: Argument $argSourceDir is not a directory or file, exiting";
    exit 1
fi
