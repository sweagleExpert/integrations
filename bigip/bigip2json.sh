#!/bin/bash

##########################################################################
#############
#############   TRANSFORM A CSV FILE AS JSON
#############
##########################################################################
if [ "$#" -lt "2" ]; then
    echo "********** ERROR: NOT ENOUGH ARGUMENTS SUPPLIED"
    echo "********** YOU SHOULD PROVIDE 1-INPUT BIGIP FILE AND 2-OUTPUT JSON FILE TO CREATE"
    exit 1
fi
FILE_IN="$1"
FILE_OUT="$2"

awk -f $(dirname "$0")/bigip2json.awk $FILE_IN > $FILE_OUT
