#!/usr/bin/env bash
#
# SCRIPT: create_mdi_types.sh
# AUTHOR: filip@sweagle>com
# DATE:   25 April 2019
# REV:    1.1.D (Valid are A, B, D, T, Q, and P)
#               (For Alpha, Beta, Dev, Test, QA, and Production)
#
# PLATFORM: Not platform dependent
#
# REQUIREMENTS:	- jq is required for this shell script to work.
#               (see: https://stedolan.github.io/jq/)
#				- tested in bash 4.4 on Mac OS X
#
# PURPOSE:	Define MDI types with regular expressions.
#			Added:
#				- boolean
#				- port range between 1024 and 9999
#				- email addresses
#				- IPv4
#				- IPv4 or IPv6
#				- URL
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
set -x   # Uncomment to debug this shell script
#
##########################################################
#               FILES AND VARIABLES 
##########################################################

# command line arguments
this_script=$(basename $0)
host=${1:-}

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

# arg1: title
# arg2: description
function create_modelchangeset() {
	title=${1}
	description=${2}

	# Create and open a new changeset
	res=$(\
		curl -sw "%{http_code}" "$sweagleURL/api/v1/model/changeset" --request POST --header "authorization: bearer $aToken"  --header 'Accept: application/vnd.siren+json' \
		--data-urlencode "title=${title}" \
		--data-urlencode "description=${description}")
	# check exit code
	rc=$?; if [ "${rc}" -ne "0" ]; then exit ${rc}; fi;
    # check http return code
	get_httpreturn httpcode res; if [ ${httpcode} -ne "200" ]; then exit 1; fi;

    cs=$(echo ${res} | jq '.properties.changeset.id')
	echo ${cs}
}


# arg1: changeset ID
# arg2: name
# arg3: description
# arg4: value_type
# arg5: required
# arg6: sensitive
# arg7: regex
function create_mdi_type() {
	changeset=${1}
	name=${2}
	description=${3:-}
	value_type=${4:-Text}
	required=${5:-false}
	sensitive=${6:-false}
	regex=${7:-}

	# Create and open a new changeset
	res=$(\
		curl -sw "%{http_code}" "$sweagleURL/api/v1/model/mdiType" --request POST --header "authorization: bearer $aToken"  --header 'Accept: application/vnd.siren+json' \
		--data "changeset=${changeset}" \
		--data-urlencode "name=${name}" \
		--data "required=${required}" \
		--data-urlencode "valueType=${value_type}" \
		--data "sensitive=${sensitive}" \
		--data-urlencode "regex=${regex}" \
		--data-urlencode "description=${description}")
	# check curl exit code
	rc=$?; if [ "${rc}" -ne "0" ]; then exit ${rc}; fi;
    # check http return code
	get_httpreturn httpcode res; if [ ${httpcode} -ne "200" ]; then exit 1; fi;

}

# arg1: changeset ID
function approve_model_changeset() {
	changeset=${1}
	# Create and open a new changeset
	res=$(curl -sw "%{http_code}" "$sweagleURL/api/v1/model/changeset/${changeset}/approve" --request POST --header "authorization: bearer $aToken"  --header 'Accept: application/vnd.siren+json')
	# check curl exit code
	rc=$?; if [ "${rc}" -ne "0" ]; then exit ${rc}; fi;
    # check http return code
	get_httpreturn httpcode res; if [ ${httpcode} -eq "200" ]; then return 0; else return 1; fi;
}

##########################################################
#               BEGINNING OF MAIN
##########################################################

set -o errexit # exit after first line that fails
set -o nounset # exit when script tries to use undeclared variables

# load sweagle host specific variables like aToken, sweagleURL, ...
source "set_param_${host}"

# create a new model changeset
modelcs=$(create_modelchangeset 'Create MDI Type' "Create a new MDI type at $(date +'%c')")


# create a MDI type for boolean values 
regex='^(?:[Tt][Rr][Uu][Ee]|[Ff][Aa][Ll][Ss][Ee])$'
create_mdi_type $modelcs boolean_14 "Boolean (true/false) values" Regex false false ${regex}

# create a MDI type for ports between 1024 and 9999
regex='^([2-9]\d{3}|1[1-9]\d\d|10[3-9]\d|102[4-9])$'
create_mdi_type $modelcs port_14 "Port numbers in the range between 1024 and 9999" Regex false false ${regex}

# create a MDI type for email addresses; see: https://www.regular-expressions.info/email.html
regex='^[a-z0-9!#$%&'"'"'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"'"'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?$'
create_mdi_type $modelcs email_14 "Email address (RFC 5322)" Regex false false ${regex}

# create a MDI type for IPv4
regex='^(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])$'
create_mdi_type $modelcs IPv4_14 "Internet Protocol version 4" Regex false false ${regex}

# create a MDI type for IPv4 and IPv6
# matches:
# 122.225.225.225
# fe80::71a3:2b00:ddd3:753f%eth0
# 2001:0db8:0000:0000:0000:ff00:0042:8329
# 2001:0db8:0000:0000:0000:ff00:0042:8329
# 2001:db8:0:0:0:ff00:42:8329
# 2001:db8:0:0:0:ff00:42:8329
# 0000:0000:0000:0000:0000:0000:0000:0001
# ::1
#
# inspired by https://www.regextester.com/104038
# TODO: may need to add non-capturing groups for performance reasons (esp. for this long regex)
regex='((^((([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5]))$)|(^((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:)))(%.+)?$))'
create_mdi_type $modelcs IPv4and6_14 "Internet Protocol version 4 and 6" Regex false false ${regex}

# create a MDI type for URL
# matches:
# http://www.example.com/index.html
# ftp://ftp.is.co.za/rfc/rfc1808.txt
# http://www.ietf.org/rfc/rfc2396.txt
# https://devtest2.sweagle.com/docs/api_v1.html
# http://example.com/mypage.html
# ftp://example.com/download.zip
# http://example.com/resource?foo=bar#fragment
#
# adapted from https://mathiasbynens.be/demo/url-regex (mind the unicode characters!!)
regex='^((https?|ftp)://)(\S+(?::\S*)?@)?(?:(?!10(?:\.\d{1,3}){3})(?!127(?:\.\d{1,3}){3})(?!169\.254(?:\.\d{1,3}){2})(?!192\.168(\.\d{1,3}){2})(?!172\.(1[6-9]|2\d|3[0-1])(\.\d{1,3}){2})([1-9]\d?|1\d\d|2[01]\d|22[0-3])(\.(?:1?\d{1,2}|2[0-4]\d|25[0-5])){2}(\.(?:[1-9]\d?|1\d\d|2[0-4]\d|25[0-4]))|(([a-z\u00a1-\uffff0-9]+-?)*[a-z\u00a1-\uffff0-9]+)(\.([a-z\u00a1-\uffff0-9]+-?)*[a-z\u00a1-\uffff0-9]+)*(\.(?:[a-z\u00a1-\uffff]{2,})))(:\d{2,5})?(/[^\s]*)?$'
create_mdi_type $modelcs URL_14 "Uniform resource locator" Regex false false ${regex}


# approve
approve_model_changeset ${modelcs}
rc=$?; if [[ "${rc}" -ne 0 ]]; then echo "Model changeset approval failed"; exit ${rc}; fi

exit 0

# End of script

