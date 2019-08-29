# SWEAGLE Integration to BIG IP equipment configuration

DESCRIPTION

This folder provides examples of script to import into SWEAGLE BIGIP network equipments configuration.

Use case is to retrieve configurations regularly to allow SWEAGLE to control its compliance and consistency, for example before deploying a new release.


PRE-REQUISITES

The scripts in this directory only does the formatting of data, so that you can import it in SWEAGLE.
You should use the scripts provided here with the scripts provided under the linux or windows directory to import configuration.


STRATEGY TO UPLOAD PROPERTIES CONTAINED IN BIGIP FILES

Recent BIGIP equipment supports API calls to export configuration as xml files.
If possible, prefer this method as XML is natively supported by SWEAGLE and you don't need and formatting script.

Legacy BIGIP configuration files are highly proprietary scripts with a mix of instructions to run and configuration to apply.
For legacy format that are text files containing { and with indentation (see example1.txt), use bigip2json.sh
The script doesn't try to understand each keywords and values, but import them as raw values to be able to handle any format and language version.

Please, note this approach may not be adapted to all use cases.


CONTENT

/bigipjson.awk : Transform a bigip text configuration into a into JSON format.
To use it: awk -f bigip2json.awk <your bigip file>
(limitations: json node name with more than 40 characters length are truncated and indexed to avoid duplicates)

/bigip2json.sh : This is just a wrapper of bigip2json.awk to facilitate usage. Launch without arguments to get help.
