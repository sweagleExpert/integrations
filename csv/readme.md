# SWEAGLE Integration to CSV files

DESCRIPTION

This folder provides examples of script to import CSV files into SWEAGLE.

Use case is to retrieve configuration regularly from excel or SQL tables that are exporting in CSV format. This will allow SWEAGLE to control configuration consistency, for example before deploying a new release.


PRE-REQUISITES

The scripts in this directory only does the formatting of data so that you can import it in SWEAGLE.
You should use the scripts provided here with the scripts provided under the linux or windows directory to import configuration.


CONTENT

/csv2json-1key.awk : Transform a comma separated file (CSV) into JSON format. This is simplified version of csv2json.awk that only takes first column as key.
You can change the separator (default is ,) by editing value of FS parameter (line 5 of the script).
To use it: awk -f csv2json-1key.awk <your csv file>
(limitations: values including line break or separator are skipped and logged)

/csv2json.awk : Transform a comma separated file (CSV) into JSON format based on number of key columns provided (default 1 if not provided). Key columns must be ordered and placed as first columns in the file.
You can change the separator (default is ,) by editing value of FS parameter (line 9 of the script).
To use it: awk -v nbKeys=<nb of key columns> -f csv2json.awk <your csv file>
(limitations: duplicate keys, values including line break or separator are skipped and logged)

/csv2json.sh : This is just a wrapper of csv2json.awk to facilitate usage. Launch without arguments to get help.
