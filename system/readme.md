# SWEAGLE Integration to LINUX SYSTEM

DESCRIPTION

This folder provides examples of script to import LINUX systems configuration into SWEAGLE

Use case is to discover & retrieve on site configuration regularly to allow SWEAGLE to control configuration consistency, for example checking the patch level is correct or a package is present before deploying a new release requiring it.

PRE-REQUISITES

The scripts in this directory only does the formatting of data so that you can import it in SWEAGLE.
You should use the scripts provided here with the scripts provided under the linux directory to import configuration.



CONTENT

/system2ini.sh : export various linux confidution items into ini and json files
