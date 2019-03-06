#!/usr/bin/env bash

##########################################################################
#############
#############   TRANSFORM A TNSNAMES.ORA FILE AS XML
#############
##########################################################################
if [ "$#" -lt "2" ]; then
    echo "********** ERROR: NOT ENOUGH ARGUMENTS SUPPLIED"
    echo "********** YOU SHOULD PROVIDE 1-INPUT TNSNAMES.ORA FILE AND 2-OUTPUT FILE"
    exit 1
fi
FILE_IN="$1"
FILE_OUT="$2"

sweagleScriptDir=$(dirname "$0")

# Remove all commented lines
sed -E  "/^(#.*)$/d" $FILE_IN > $FILE_OUT.tmp

# Do the XML transfo
awk -f $sweagleScriptDir/tns2xml.awk $FILE_OUT.tmp > $FILE_OUT

rm $FILE_OUT.tmp
