#!/bin/bash
echo "################################################"
echo "#####     CREATING TENANT V1.0.1"
echo "################################################"

##########################################################
#                    UTILITIES FUNCTIONS
#               (USED BY SWEAGLE API FUNCTIONS)
##########################################################
OK=0
SYSTEM_ERROR=1
INSUFFICIENT_ARGS=2
SYNTAX_ERROR=3
FILE_NOT_FOUND=4
SWEAGLE_ERROR=5

# manage errors from CURL to SWEAGLE
# inputs are curl returned code and response
function handleErrors() {
  rc=$1
  response=$2
  # check curl exit code
  if [ ${rc} -ne 0 ]; then echo "ERROR: CURL exit code ${rc}"; return ${rc}; fi;
  # check http_code returned
  http_code=$(echo "$response"| tail -c 4)
  response=$(echo "${response::-3}")
  if [[ "${http_code}" != 20* ]]; then echo "ERROR HTTP ${http_code}: SWEAGLE response ${response}"; return ${http_code}; fi;
  # check sweagle error
  errorFound=$(echo $response | jsonValue "error_description")
  if [[ -z $errorFound ]]; then
    echo "$response"
    return $OK
  else
    echo "### ERROR IN SWEAGLE: $errorFound"
    return $SWEAGLE_ERROR
  fi
}

# extract the value of a json key from json string (if present)
# inputs are key to search for, and number of the occurrence to extract (default 1 if none provided)
function jsonValue() {
   key=$1
   if [[ -z "$2" ]]; then
      num=1
   else
      num=$2
   fi
   awk -F"[,:}]" '{for(i=1;i<=NF;i++){if($i~/\042'$key'\042/){print $(i+1)}}}' | tr -d '"' | sed -n ${num}p
}


##########################################################
#                    MAIN
##########################################################
echo "#####     VALIDATE INPUTS PROVIDED"
echo " TENANT = ${SWEAGLE_TENANT}"

if [[ -z ${SWEAGLE_ADMIN_USER} ]]; then
  echo " No admin user provided, using default"
  SWEAGLE_ADMIN_USER="admin_${SWEAGLE_TENANT}"
fi
echo " USER = ${SWEAGLE_ADMIN_USER}"

if [[ -z ${SWEAGLE_ADMIN_PASSWORD} ]]; then
  echo " No admin password provided, using default"
  SWEAGLE_ADMIN_PASSWORD="password"
fi
echo " PASSWORD = ${SWEAGLE_ADMIN_PASSWORD}"

if [[ -z ${SWEAGLE_ADMIN_EMAIL} ]]; then
  echo " No admin email provided, using default"
  SWEAGLE_ADMIN_EMAIL="${SWEAGLE_ADMIN_USER}@${SWEAGLE_TENANT}.com"
fi
echo " EMAIL = ${SWEAGLE_ADMIN_EMAIL}"

if [[ -z ${SWEAGLE_URL} ]]; then
  echo " No url provided, using default"
  SWEAGLE_URL="http://sweagle-core:8081"
fi
echo " URL = ${SWEAGLE_URL}"

echo "#####     LAUNCH CREATE TENANT CURL"
for i in {1..12}; do
  # loop will break automatically if curl returns 0
  response=$(curl -skw "%{http_code}" -X POST "${SWEAGLE_URL}/internal/root/tenant" \
    -F "tenantName="$SWEAGLE_TENANT \
    -F "tenantDescription="${SWEAGLE_TENANT}"_tenant" \
    -F "username="$SWEAGLE_ADMIN_USER \
    -F "name="$SWEAGLE_ADMIN_USER \
    -F "password="$SWEAGLE_ADMIN_PASSWORD \
    -F "email="$SWEAGLE_ADMIN_EMAIL) && break

  if [[ $i -lt 12 ]]; then
    echo "## ERROR ON TRY $i ## curl return code is invalid, waiting 10s for sweagle-core to be available"
    sleep 10
  else
    echo "## LAST TRY $i FAILED ## unable to connect to sweagle-core"
    echo "## Please check URL=${SWEAGLE_URL} is correct and relaunch container"
    exit 1
  fi
done

echo "#####     CHECK RESPONSE"
response=$(handleErrors $? "${response}")
echo -e "## CREATE TENANT RESPONSE =\n${response}"
