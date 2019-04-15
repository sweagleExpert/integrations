# SWEAGLE Integration to CISCO equipment configuration

DESCRIPTION

This folder provides examples of script to import into SWEAGLE CISCO network equipments configuration.

Use case is to retrieve configurations regularly to allow SWEAGLE to control its compliance and consistency, for example before deploying a new release.


PRE-REQUISITES

The scripts in this directory only does the formatting of data, so that you can import it in SWEAGLE.
You should use the scripts provided here with the scripts provided under the linux or windows directory to import configuration.


STRATEGY TO UPLOAD PROPERTIES CONTAINED IN CISCO FILES

CISCO configuration files are highly proprietary scripts with a mix of instructions to run and configuration to apply.
Strategy to import them efficiently in SWEAGLE is:
- first, to focus only on parameters that will be used for validation rules, and not try to import everything;
- second, not try to understand each CISCO keywords and values, but import them as raw values to be able to handle any format and language version.

Please, note this is a direct approach that may not be adapted to all use cases.


CONTENT

/cisco2json.sh : transform a CISCO script file into JSON format for selected parameters list.
For each keyword put in parameters list, the script considers keyword as key and rest of the line as value.
If multiple values are present, it will transform them in json array.
