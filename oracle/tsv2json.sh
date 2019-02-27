#!/usr/bin/env bash

##########################################################################
#############
#############   TRANSFORM A TSV FILE AS JSON
#############
##########################################################################
if [ "$#" -lt "2" ]; then
    echo "********** ERROR: NOT ENOUGH ARGUMENTS SUPPLIED"
    echo "********** YOU SHOULD PROVIDE 1-INPUT TSV FILE AND 2-OUTPUT JSON FILE TO CREATE"
    echo "********** (OPTIONAL) 3- NB OF COLUMN TO USE AS KEYS (DEFAULT 1)"
    echo "********** KEY(S) COLUMNS ARE USED AS JSON NODES AND SHOULD BE FIRST COLUMNS"
    exit 1
fi
FILE_IN="$1"
FILE_OUT="$2"
if [ ! -z "$3" ]; then
  NB_KEYS_COLUMN=$3
else
  NB_KEYS_COLUMN=1
fi

awk -v nbKeys=$NB_KEYS_COLUMN -f tsv2json.awk $FILE_IN > $FILE_OUT
