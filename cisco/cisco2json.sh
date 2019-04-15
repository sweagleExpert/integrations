#!/usr/bin/env bash

##########################################################################
#############
#############   EXTRACT CISCO CONFIG
#############
############# Output: 0 if no errors, 1 + Details of errors if any
##########################################################################
if [ "$#" -lt "2" ]; then
    echo "********** ERROR: NOT ENOUGH ARGUMENTS SUPPLIED"
    echo "********** YOU SHOULD PROVIDE 1-INPUT FILE 2-OUTPUT FILE"
    exit 1
fi
SOURCE_FILE=$1
OUTPUT_FILE=$2

# DECLARE HERE LIST OF KEYS to SEARCH
KEYS=("hostname"
  "ASA Version"
  "version"
  " ip address"
  "logging host"
  "snmp-server enable traps"
  "snmp-server host "
  "ip ssh rsa keypair-name")

IFS="
"

function ltrim() { echo $1|awk '{sub(/^[ \t\r\n]+/, "", $0); print $0}'; }
function rtrim() { echo $1|awk '{sub(/[ \t\r\n]+$/, "", $0); print $0}'; }
function trim() { echo $1|awk '{sub(/^[ \t\r\n]+/, "", $0); sub(/[ \t\r\n]+$/, "", $0); print $0}'; }
function escapeJSON() { echo $1|awk '{gsub(/(  |\r|\")/, "", $0); print $0}'; }

# Put all lines in comment
#sed  -e 's/^/#/' $SOURCE_FILE > $OUTPUT_FILE.tmp
echo "{" > $OUTPUT_FILE
for key in "${KEYS[@]}"
do
  nbLines=$(grep -c '^'$key $SOURCE_FILE)
  echo "- matching key ($key) occurs $nbLines"
  if [[ "$nbLines" -gt 1 ]]; then
    # this is a list start a json array
    echo "\"$(trim $key)\":[" >> $OUTPUT_FILE
    RESULT_LIST=$(grep '^'$key $SOURCE_FILE)
    for line in $RESULT_LIST; do
      value=${line/$key/}
      value=$(trim $value)
      echo "\"$(escapeJSON $value)\"," >> $OUTPUT_FILE
    done
    # Replace last , by end of json array ],
    sed -i '$ s/,/],/' $OUTPUT_FILE

  elif [[ "$nbLines" -gt 0 ]]; then
    # there is at least one item
    line=$(grep '^'$key $SOURCE_FILE)
    value=${line/$key/}
    value=$(trim $value)
    value=$(escapeJSON $value)
    echo "\"$(trim $key)\":\"$value\"," >> $OUTPUT_FILE
  fi
done
# Replace last , by end of json }
sed -i '$ s/,/\}/' $OUTPUT_FILE
