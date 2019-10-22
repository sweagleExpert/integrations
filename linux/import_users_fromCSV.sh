#!/usr/bin/env bash
#
# SCRIPT: import_users_fromCSV.sh
# AUTHOR: dimitris@sweagle.com
# DATE:   October 2019
# REV:    1.0.D (Valid are A, B, D, T, Q, and P)
#               (For Alpha, Beta, Dev, Test, QA, and Production)
#
# PLATFORM: Not platform dependent
#
# REQUIREMENTS:	- jq is required for this shell script to work.
#               (see: https://stedolan.github.io/jq/)
#				- tested in bash 4.4
#
# PURPOSE:	Import users from CSV with a default role
#						CSV columns must be LOGIN,PASSWORD,EMAIL,NAME,ROLE
#
# REV LIST:
#        DATE: DATE_of_REVISION
#        BY:   AUTHOR_of_MODIFICATION
#        MODIFICATION: Describe what was modified, new features, etc--
#
#
# set -n   # Uncomment to check script syntax, without execution
#          # NOTE: Do not forget to put the # comment back in or
#          #       the shell script will never execute!
#set -x   # Uncomment to debug this shell script
#
##########################################################
#               CHECK PREREQUISITES
##########################################################
if ! [ -x "$(command -v jq)" ] ; then
  echo "#########################################################################################"
  echo "########## WARNING: As JQ is not installed, update user and role assignment won't work"
  echo "#########################################################################################"
fi

if [ $# -lt 1 ]; then
    echo "########## ERROR: NOT ENOUGH ARGUMENTS SUPPLIED"
    echo "********** YOU SHOULD PROVIDE 1- CSV FILE WITH COLUMNS LOGIN,PASSWORD,EMAIL,NAME,ROLE"
		echo "********** YOU MAY PROVIDE 2- COLUMN SEPARATOR (OPTIONAL, DEFAULT IS ,)"
    exit 1
fi

##########################################################
#               FILES AND VARIABLES
##########################################################
# command line arguments
this_script=$(basename $0)
host=${1:-}
# load sweagle host specific variables like aToken, sweagleURL, ...
source $(dirname "$0")/sweagle.env

# check if a column separator arg was provided
if [ $# -lt 2 ]; then separator=','; else separator=$2; fi
# Define number regex
numberRegex='^[0-9]+$'

##########################################################
#                    FUNCTIONS
##########################################################

# arg1: http result (incl. http code)
# arg2: httpcode (by reference)
function get_httpreturn() {
	local -n __http=${1}
	local -n __res=${2}

	__http="${__res:${#__res}-3}"
    if [ ${#__res} -eq 3 ]; then
      __res=""
    else
      __res="${__res:0:${#__res}-3}"
    fi
}

# arg1: rolename
# Global variable users_list is also used
function get_role() {
  rolename=${1}

  # Get all tenant roles
	res=$(curl -sw "%{http_code}" "$sweagleURL/api/v1/tenant/role" --request GET --header "authorization: bearer $aToken"  --header 'Accept: application/vnd.siren+json')

	# check curl exit code
	rc=$?; if [ "${rc}" -ne "0" ]; then exit ${rc}; fi;
    # check http return code
	get_httpreturn httpcode res; if [ ${httpcode} -ne "200" ]; then exit 1; fi;

  id=$(echo ${res} | jq --arg attr_rolename ${rolename} '.entities[].properties | select(.name|index($attr_rolename)) | .id')
	echo ${id}
}

function get_users() {
	# Get all tenant users
	res=$(curl -sw "%{http_code}" "$sweagleURL/api/v1/user" --request GET --header "authorization: bearer $aToken"  --header 'Accept: application/vnd.siren+json')

	# check curl exit code
	rc=$?; if [ "${rc}" -ne "0" ]; then exit ${rc}; fi;
    # check http return code
	get_httpreturn httpcode res; if [ ${httpcode} -ne "200" ]; then echo $res; exit 1; fi;

	echo ${res}
}

# arg1: username
# Global variable users_list is also used
function get_user_from_username() {
  username=${1}

  if [ -x "$(command -v jq)" ] ; then
    id=$(echo ${users_list} | jq --arg attr_username ${username} '.entities[].properties | select(.username|index($attr_username)) | .id')
  else
    id=$(echo ${users_list} | grep ${username})
  fi

	echo ${id}
}

# arg1: email
# Global variable users_list is also used
function get_user_from_email() {
  email=${1}

  if [ -x "$(command -v jq)" ] ; then
    id=$(echo ${users_list} | jq --arg attr_email ${email} '.entities[].properties | select(.email|index($attr_email)) | .id')
  else
    id=$(echo ${users_list} | grep ${email})
  fi

	echo ${id}
}

# arg1: username
# arg2: email
# arg3: name
# arg4: password
# arg5: disabled (true, false)
# arg6: userType (PERSON, API, SYSTEM)
# arg7: roles (comma separated list of roles)
function create_user() {
	username=${1}
	email=${2}
	name=${3}
	password=${4:-"testtest"}
	disabled=${5:-false}
	userType=${6:-"PERSON"}
	roles=${7:-}

	res=$(\
		curl -sw "%{http_code}" "$sweagleURL/api/v1/user" --request POST --header "authorization: bearer $aToken"  --header 'Accept: application/vnd.siren+json' \
		--data "username=${username}" \
		--data-urlencode "email=${email}" \
		--data-urlencode "name=${name}" \
		--data-urlencode "password=${password}" \
		--data "disabled=${disabled}" \
		--data "userType=${userType}" \
		--data-urlencode "roles=${roles}")
	# check curl exit code
	rc=$?; if [ "${rc}" -ne "0" ]; then exit ${rc}; fi;
    # check http return code
	get_httpreturn httpcode res; if [ ${httpcode} -ne "200" ]; then echo ${res}; exit 1; fi;
}

# arg1: id (user id)
# arg2: username
# arg3: email
# arg4: name
# arg5: currentPassword
# arg6: newPassword
# arg7: disabled (true, false)
function update_user() {
	id=${1}
	username=${2-}
	email=${3}
	name=${4}
	currentPassword=${5:-"testtest"}
	newPassword=${6:-}
	disabled=${7:-false}

	# Update an existing user
	res=$(\
		curl -sw "%{http_code}" "$sweagleURL/api/v1/user/${id}" --request POST --header "authorization: bearer $aToken"  --header 'Accept: application/vnd.siren+json' \
		--data "username=${username}" \
		--data-urlencode "email=${email}" \
		--data-urlencode "name=${name}" \
		--data-urlencode "currentPassword=${currentPassword}" \
		--data-urlencode "password=${newPassword}" \
		--data-urlencode "rwPassword=${newPassword}" \
		--data "disabled=${disabled}")
	# check curl exit code
	rc=$?; if [ "${rc}" -ne "0" ]; then exit ${rc}; fi;
    # check http return code
	get_httpreturn httpcode res; if [ ${httpcode} -ne "200" ]; then echo ${res}; exit 1; fi;
}


##########################################################
#               BEGINNING OF MAIN
##########################################################
#set -o errexit # exit after first line that fails
set -o nounset # exit when script tries to use undeclared variables

# Get list of existing users in SWEAGLE
users_list=$(get_users)

# read CSV file skipping first line which is header
sed 1d $1 | while IFS=${separator} read -r username password email name role
do
	#echo "### Read line $username, $email, $name, $role"
	userID=$(get_user_from_username ${username})
  if [ ! -z "$userID" ]; then
    # User already exists, check if we got his id or just result of a grep
    if [[ $userID =~ $numberRegex ]]; then
      echo "### user ${username} already exits, update it"
  		res=$(update_user ${userID} "" "${email}" "${name}")
  		rc=$?; if [[ "${rc}" -ne 0 ]]; then echo "UPDATE FAILED WITH ERROR: $res"; else echo "UPDATE SUCCESSFULL"; fi
    else
      # We got only result of a grep, skip it
      echo "### user ${username} already exits, skip it"
    fi
  else
    userID=$(get_user_from_email ${email})
    if [ ! -z "$userID" ]; then
      # User already exists, check if we got his id or just result of a grep
      if [[ $userID =~ $numberRegex ]]; then
        echo "### user ${email} already exits, update it"
    		res=$(update_user ${userID} "${username}" "${email}" "${name}")
    		rc=$?; if [[ "${rc}" -ne 0 ]]; then echo "UPDATE FAILED WITH ERROR: $res"; else echo "UPDATE SUCCESSFULL"; fi
      else
        # We got only result of a grep, skip it
        echo "### user ${email} already exits, skip it"
      fi
    else
      echo "### No existing user ${username}, create it"
      roleID="";
      if [[ $role =~ $numberRegex ]]; then
        # If role is already a number, use it as role ID
        roleID=${role}
      elif [ -x "$(command -v jq)" ] ; then
        roleID=$(get_role ${role})
      fi
      if [ -z "${roleID}" ]; then
        res=$(create_user "${username}" "${email}" "${name}" "${password}" false "PERSON")
      else
        echo "Found role with ID: ${roleID}"
    		res=$(create_user "${username}" "${email}" "${name}" "${password}" false "PERSON" "${roleID}")
      fi
  		rc=$?; if [[ "${rc}" -ne 0 ]]; then echo "CREATION FAILED WITH ERROR: $res"; else echo "CREATION SUCCESSFULL";  fi
    fi
  fi
done

exit 0
# End of script
