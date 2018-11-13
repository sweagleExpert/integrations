#!/usr/bin/env bash
source $(dirname "$0")/ldap.env

##########################################################################
#############
#############   RETRIEVE LIST OF USERS TO UPLOAD IN SWEAGLE
#############
############# Inputs:
############# - Source file to store (this config file should be obtained from Sweagle)
############# - Gitlab target folder to store file
############# Source filename is used as target filename in GitLab
#############
############# Output: 0 if no errors, 1 + Details of errors if any
##########################################################################



curl "ldap://$ldapHost:$ldapPort/$ldapUsersOrg?$swLogin,$swName,$swEmail?sub?(ObjectClass=person)" -u "$ldapUser":$ldapPassword
