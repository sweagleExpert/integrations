# SWEAGLE Integration to ORACLE database
DESCRIPTION

This folder provides examples of script to import into SWEAGLE configurations from ORACLE database tables containing properties.
Use case is to retrieve configuration regularly to allow SWEAGLE to control configuration consistency, for example before deploying a new release.

If you want to know more on exporting configuration from SWEAGLE to ORACLE, please check:
https://github.com/sweagleExpert/templates/tree/master/oracle

PRE-REQUISITES

The scripts in this directory only does the formatting of data so that you can import it in SWEAGLE.
You should use the scripts provided here with the scripts provided under the linux or windows directory to import configuration.


STRATEGY

The best strategy when getting configuration from a database is to try to simplify data pump by transforming into a property file format, using SQL query like:
SELECT <YOUR_KEY_COLUMN> || '=' || <YOUR_VALUE_COLUMN> FROM <YOUR_TABLE>;

The sample files provided here handles more complex use cases when database table contains more than 2 columns to extract. It is based on the fact that you get regularly full export of your table in TSV format.


CONTENT

/tsv2json.sh : Generate a JSON file from a TSV file, with table Keys as node of the JSON. Launch without arguments to get help.
(limitations: values including line break may cause issues)

/tsv2json.jq : Generate a JSON file from a TSV file using jq library. It is more powerful and quicker than previous shell script but requires JQ to be installed
(limitations: all values are put in array of JSON list with no parent node)
