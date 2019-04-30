# SWEAGLE Integration to SQUID configuration

DESCRIPTION

This folder provides examples of script to import into SWEAGLE SQUID configuration.

Use case is to retrieve configurations regularly to allow SWEAGLE to control its compliance and consistency, for example before deploying a new release.


PRE-REQUISITES

The scripts in this directory only does the formatting of data, so that you can import it in SWEAGLE.
You should use the scripts provided here with the scripts provided under the linux or windows directory to import configuration.


STRATEGY TO UPLOAD PROPERTIES CONTAINED IN SQUID FILES

SQUID configuration file (squid.conf) is following a specific format with a mix of instructions to run and configuration to apply.
Strategy to import them efficiently in SWEAGLE is:
- first, to focus only on parameters that will be used for validation rules, and not try to import everything;
- second, not try to understand each SQUID keywords and values, but import them as raw values to be able to handle any format and language version.

Please, note this is a direct approach that may not be adapted to all use cases.


CONTENT

/squid2json.sh : transform a squid.conf file into JSON format for selected parameters list.
For each keyword put in parameters list, the script considers keyword as key and rest of the line as value.
For each keyword, you should also define in which JSON elements values will be stored. Each JSON element is transformed into a node in SWEAGLE.
For example:
KEYS["acl Safe_ports port"]="acl/safe/ports" means you will create JSON elements {"acl" : {"safe" : {"ports" : "<value>"}}}

If multiple values are present, script will transform them in json array.
