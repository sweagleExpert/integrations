#!/usr/bin/env bash

##########################################################################
#############
#############   EXTRACT SQUID CONFIG to JSON FORMAT
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

# Define here the list of keys to extract from conf file and target JSON element
# If target json element is empty, it will use key as json element
declare -A KEYS;
KEYS["http_port"]="";
KEYS["acl localnet src"]="acl-localnet/src";
KEYS["acl SSL_ports port"]="acl-SSL_ports/port";
KEYS["acl Safe_ports port"]="acl-Safe_ports/port"
KEYS["http_access allow"]="http_access-allow";
KEYS["http_access deny"]="http_access-deny";
KEYS["icp_port"]="icp_port";
KEYS["authenticate_ttl"]="";
KEYS["ident_timeout"]="";
KEYS["cache_peer"]="";
KEYS["cache_effective_user"]="";
KEYS["cache_effective_group"]="";
KEYS["cache_dir"]="";
KEYS["cache_log"]="";
KEYS["coredump_dir"]="";
KEYS["dns_defnames"]="";
KEYS["pid_filename"]="";
KEYS["never_direct"]="";
KEYS["visible_hostname"]="";

IFS="
"

function ltrim() { echo $1|awk '{sub(/^[ \t\r\n]+/, "", $0); print $0}'; }
function rtrim() { echo $1|awk '{sub(/[ \t\r\n]+$/, "", $0); print $0}'; }
function trim() { echo $1|awk '{sub(/^[ \t\r\n]+/, "", $0); sub(/[ \t\r\n]+$/, "", $0); print $0}'; }
function escapeJSON() { echo $1|awk '{gsub(/(  |\r|\")/, "", $0); print $0}'; }

# Remove all commented lines and comments at end of lines
sed 's/#.*$//g' $SOURCE_FILE > $OUTPUT_FILE.tmp
sed -i '/^[[:space:]]*$/d' $OUTPUT_FILE.tmp

# Put all lines in comment
echo "{" > $OUTPUT_FILE
#for key in "${KEYS[@]}" ; do
for elem in ${!KEYS[*]}; do
  # retrieve the key to search and JSON element
  key="${elem}"
  node=${KEYS[$key]}
  echo "key=$key"
  echo "json=$node"
  if [[ -z "$node" ]]; then
   #json target element is emtpty, replace by key
   node=$key
  else
    # json target element not empty, build json
    in="/"
    out="\":{\""
    node=$(echo "${KEYS[$key]//$in/$out}")
  fi
  node_end=$(echo "${node//'{'/'}'}" | tr -cd '}')
  echo "node=$node"

  nbLines=$(grep -c '^'$key $OUTPUT_FILE.tmp)
  echo "- matching key ($key) occurs $nbLines"
  if [[ "$nbLines" -gt 1 ]]; then
    # this is a list start a json array
    echo "\"$node\":[" >> $OUTPUT_FILE
    RESULT_LIST=$(grep '^'$key $OUTPUT_FILE.tmp)
    for line in $RESULT_LIST; do
      value=${line/$key/}
      value=$(trim $value)
      echo "\"$(escapeJSON $value)\"," >> $OUTPUT_FILE
    done
    # Replace last , by end of json array ],
    sed -i '$ s/,/]/' $OUTPUT_FILE
    echo "$node_end," >> $OUTPUT_FILE

  elif [[ "$nbLines" -gt 0 ]]; then
    # there is at least one item
    line=$(grep '^'$key $OUTPUT_FILE.tmp)
    value=${line/$key/}
    value=$(trim $value)
    value=$(escapeJSON $value)
    echo "\"$node\":\"$value\"$node_end," >> $OUTPUT_FILE
  fi
done
# Replace last , by end of json }
sed -i '$ s/,/\}/' $OUTPUT_FILE
rm $OUTPUT_FILE.tmp
