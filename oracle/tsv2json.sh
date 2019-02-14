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

function escape_json_chars() {
  var=$1
  # Replace Backslash by slash (normally should be replaced by double backslash)
  var=$(echo "$var" | sed 's/\\/\//g')
  #var=$(echo $var | sed 's/\\\\/\\\\\\\\/g')
  # Escape windows EOL characters
  var=$(echo -e "$var" | tr -d '\n')
  var=$(echo -e "$var" | tr -d '\r')
  # Escape double quotes in values not empty
  if [[ $var != "\"\"" ]]; then
    var=$(echo "$var" | sed 's/\"\"/\\\"/g')
  fi
  # Put under double quotes values that don't have
  # This also put double quotes for empty values
  if [[ $var != "\""* ]]; then
    var="\"$var\""
  fi
  echo $var
}


LINE_COUNT=1
LAST_LINE=$(<"$FILE_IN" wc -l)
EOR=""
KEY_ARRAY=()
echo '{' > $FILE_OUT
while IFS=$'\t' read -r -a LINE_ARRAY
do
  NBC=${#LINE_ARRAY[@]}
  # For debugging: echo 'number of columns:' $NBC
  if [ $LINE_COUNT -gt 1 ]; then
    # Manage Value lines
    i=0
    JSON_RECORD=""
    # Manage Key columns
    #For debugging: echo "Handling line: "$LINE_COUNT
    while ((i < $NB_KEYS_COLUMN)); do
      if [ "${KEY_ARRAY[$i]}" !=  "${LINE_ARRAY[$i]}" ]; then
        # This is new key, start a node
        if [ -z "${KEY_ARRAY[$i]}" ]; then
          # first value line, we just start newkey
          #echo ${LINE_ARRAY[$i]}': {' >> $FILE_OUT
          JSON_RECORD="$JSON_RECORD ${LINE_ARRAY[$i]}: {"
        else
          count=$(($NB_KEYS_COLUMN-$i))
          j=1
          EOR=""
          while ((j < $count)); do
            EOR=$EOR'}'
            ((j+=1))
          done
          # other value line, we finish other record before starting newkey
          #echo $EOR ',' ${LINE_ARRAY[$i]}': {' >> $FILE_OUT
          JSON_RECORD="$JSON_RECORD $EOR, ${LINE_ARRAY[$i]}: {"

        fi
        if [ $i -eq 0 ]; then
          # reinitialize array if starting a new root node
          KEY_ARRAY=()
        fi
        KEY_ARRAY[$i]=${LINE_ARRAY[$i]}
      fi
      ((i+=1))
    done
    # Manage Value columns
    i=0
    while ((i < $LAST_COLUMN)); do
      value=$(escape_json_chars "${LINE_ARRAY[$i]}")
      #echo ${LINE_HEADER[$i]}': '$value',' >> $FILE_OUT
      JSON_RECORD="$JSON_RECORD ${LINE_HEADER[$i]}: $value,"
      ((i+=1))
    done
    # Manage last column
    value=$(escape_json_chars "${LINE_ARRAY[$i]}")
    #echo ${LINE_HEADER[$i]}': '$value >> $FILE_OUT
    JSON_RECORD="$JSON_RECORD ${LINE_HEADER[$i]}: $value}"
    if [ $LINE_COUNT -eq $LAST_LINE ]; then
      # Last line, close the json record
      j=1
      EOR="}"
      while ((j < $NB_KEYS_COLUMN)); do
        EOR=$EOR'}'
        ((j+=1))
      done
      #echo $EOR >> $FILE_OUT
      JSON_RECORD="$JSON_RECORD $EOR"
    fi
    echo $JSON_RECORD  >> $FILE_OUT
  else
    # Store header line
    LINE_HEADER=("${LINE_ARRAY[@]}")
    NB_COLUMNS=${#LINE_ARRAY[@]}
    LAST_COLUMN=`expr $NB_COLUMNS - 1`
  fi
  ((LINE_COUNT+=1))
done < $FILE_IN
