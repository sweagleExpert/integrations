#!/usr/bin/env bash

##########################################################################
#############
#############   TRANSFORM FIRST COLUMN OF CSV FILE INTO JSON
#############
##########################################################################
if [ "$#" -lt "2" ]; then
    echo "********** ERROR: NOT ENOUGH ARGUMENTS SUPPLIED"
    echo "********** YOU SHOULD PROVIDE 1-INPUT CSV FILE AND 2-OUTPUT JSON FILE TO CREATE"
    echo "********** (OPTIONAL) 3- NAME OF COLUMN (if you want to replace it)"
    exit 1
fi

if ! [[ -f "$1" ]] ; then
    echo "********** ERROR: Argument $1 is not a file, exiting";
    exit 1
else
  argSourceFile=$1
fi
argTargetFile=$2

if [[ -n "$3" ]] ; then
  argName=$3
else
  argName=$(head -1 ${argSourceFile} | awk -F"," '{print toupper($1)}')
fi

# Create json array name
echo "{\"${argName}\" : [" > ${argTargetFile}

# Get first column values in uppercase to a new file (remove first line with NR>1)
awk -F"," 'NR>1 {printf "\"%s\",",toupper($1)}' ${argSourceFile} >> ${argTargetFile}

# replace last , by ]} to end json
sed -i '$ s/.$/]}/' ${argTargetFile}


# Replace first line, which is header, by the argName
#sed -i "1s/.*/$3/" $2
