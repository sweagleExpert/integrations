#!/usr/bin/env bash
#
# SCRIPT: recognizeNodeTypes.sh
# AUTHOR: dimitris@sweagle.com
# DATE:   September 2019
# REV:    1.0.D (Valid are A, B, D, T, Q, and P)
#               (For Alpha, Beta, Dev, Test, QA, and Production)
#
# PLATFORM: Not platform dependent
#
# REQUIREMENTS:	N/A
#
# PURPOSE:		Identify in datamodel what nodes correspond to an existing node type
#							through Machine Learning algorythm
#
# REV LIST:
#        DATE: DATE_of_REVISION
#        BY:   AUTHOR_of_MODIFICATION
#        MODIFICATION: Describe what was modified, new features, etc--
#
#
# set -n   # Uncomment to check script syntax, without execution.
#          # NOTE: Do not forget to put the # comment back in or
#          #       the shell script will never execute!
# set -x   # Uncomment to debug this shell script
#
##########################################################
#               FILES AND VARIABLES
##########################################################

# Check command line arguments
if [ "$#" -lt "1" ]; then
    echo "########## ERROR: NOT ENOUGH ARGUMENTS SUPPLIED"
    echo "########## YOU SHOULD PROVIDE 1-NODEPATH"
    exit 1
fi
this_script=$(basename $0)
argNodePath=${1}

# load sweagle host specific variables like aToken, sweagleURL, ...
source $(dirname "$0")/sweagle.env

##########################################################
#                    FUNCTIONS
##########################################################

# arg1: nodepath
function recognize_node_types() {
	nodepath=${1}

	res=$(\
	  curl -skw "%{http_code}" "$sweagleURL/api/v1/data/ml/recognize?" --request POST --header "authorization: bearer $aToken"  --header 'Accept: application/vnd.siren+json' \
			--data "downLimit=100" \
			--data-urlencode "path=$nodepath" )
	# check curl exit code
	rc=$?; if [ "${rc}" -ne "0" ]; then exit ${rc}; fi;
  # check http return code
	get_httpreturn httpcode res; if [[ "${httpcode}" != 20* ]]; then echo ${res}; exit 1; fi;
	if [ ${httpcode} -eq 204 ]; then echo  "### NO MATCH FOUND ###"; exit 0; fi;

	#if [ -x "$(command -v jq)" ]; then
		# If JQ library is present, extract changeset title from response
	#	csTitle=$(echo ${response} | jq '.properties.changeset.title')
	#	echo "### MATCHING FOUND ###\n# For more details, see changeset \"$csTitle\""
	#else
		echo "### MATCHING FOUND ###\n# For more details, see last changeset with title containing \"api recognition changeset\""
	#fi
}


##########################################################
#               BEGINNING OF MAIN
##########################################################

#set -o errexit # exit after first line that fails
set -o nounset # exit when script tries to use undeclared variables

recognizeResult=$(recognize_node_types ${argNodePath})
echo -e ${recognizeResult}

exit 0
# End of script
