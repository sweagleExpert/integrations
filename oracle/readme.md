# SWEAGLE Integration to ORACLE database
DESCRIPTION

This folder provides examples of script to import into SWEAGLE
1. Oracle database instances configurations contained in tnsnames.ora file
2. Configurations of applications contained in ORACLE database tables

Use case is to retrieve configuration regularly to allow SWEAGLE to control configuration consistency, for example before deploying a new release.

If you want to know more on exporting configuration from SWEAGLE to ORACLE, please check:
https://github.com/sweagleExpert/templates/tree/master/oracle


PRE-REQUISITES

The scripts in this directory only does the formatting of data so that you can import it in SWEAGLE.
You should use the scripts provided here with the scripts provided under the linux or windows directory to import configuration.


STRATEGY TO UPLOAD PROPERTIES CONTAINED IN ORACLE TABLES

For most use cases, the best strategy in term of performance is to directly get a JSON object from ORACLE using SELECT JSON_OBJECTAGG or SELECT JSON_OBJECT functions.
See description here: https://docs.oracle.com/en/database/oracle/oracle-database/12.2/sqlrf/JSON_OBJECT.html#GUID-1EF347AE-7FDA-4B41-AFE0-DD5A49E8B370
But this may not work due to ORACLE limitations in input/output size before version 18c.

Another strategy when getting configuration from a database is to try to simplify data pump by transforming into a property file format, using SQL query like:
SELECT <YOUR_KEY_COLUMN> || '=' || <YOUR_VALUE_COLUMN> FROM <YOUR_TABLE>;

For more complex use cases, you may get regular export of your tables in TSV format.
The sample files provided here handles this when database table contains more than 2 columns to extract.

CONTENT

/selectJSON.sql : Examples of PL/SQL queries to directly extract JSON format from tables

/tns2xml.awk : Transform a tnsnames.ora file into XML format.
To use it: awk -f tns2xml.awk <your tns file> > <your target xml file>
(limitations: you should remove comment lines from your file)

/tns2xml.sh : This is just a wrapper of tns2xml.awk to facilitate usage. Launch without arguments to get help. This wrapper will remove the limitations of awk version by removing commented lines before executing awk script.

/tsv2json.awk : Transform a tab separated file (TSV) into JSON format based on number of key columns provided (default 1 if not provided). Key columns must be ordered and placed as first columns in the file.
To use it: awk -v nbKeys=<nb of key columns> -f tsv2json.awk <your tsv file>
(limitations: duplicate keys, values including line break or separator are skipped and logged)

/tsv2json.sh : This is just a wrapper of tsv2json.awk to facilitate usage. Launch without arguments to get help.

/tsv2json.jq : Generate a JSON file from a TSV file using jq library. Using jq  ensure a better compliance to JSON format
(limitations: This require jq to be installed. All values are put in JSON array with no parent node)
