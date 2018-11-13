# Sweagle Integration to LDAP
DESCRIPTION

This folder provides examples of configuration to integrate Sweagle with LDAP.
This integration purpose is to retrieve list of Sweagle users from an LDAP v3 compliant directory server.

PRE-REQUISITES

You should use the scripts provided here with the scripts provided under the linux or windows directory.
Especially, this script is using the createUser script and XXX.

INSTALLATION

1. Put all linux or windows Sweagle shell scripts into one folder (for example "/sweagle_scripts")
2. Open the "sweagle.env" file and put your sweagle API token as value for parameter aToken
3. Put all LDAP scripts into server and folder that has access to your LDAP server and Sweagle scrips
4. Open the "ldap.env" file and put your LDAP server values + fields mapping between LDAP and SWEAGLE
5. Launch the XXX script and check result in SWEAGLE

That's all !

CONTENT

/ldap.env         : LDAP environment settings

XXX
