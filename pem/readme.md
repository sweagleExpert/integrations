# SWEAGLE Integration to PEM certificate

DESCRIPTION

This folder provides examples of script to import PEM certificates into SWEAGLE.
Use case is to retrieve PEM information regularly in order to apply validation rules, like checking if their validity date is still ok, or verifying if CN is well defined in DNS/hosts lists, etc...

Benefits are that results of validation rules si directly available from SWEAGLE REST API to multiple consumers of the PEM certificates.

PRE-REQUISITES

The scripts in this directory only does the formatting of data so that you can import it in SWEAGLE.
You should use the scripts provided here with the scripts provided under the linux or windows directory to import configuration.
openssl must be present on the server doing the export of config data from PEM file.


TO TEST
Generate a new certificate with command line :
openssl req -newkey rsa:2048 -nodes -keyout key.pem -x509 -days 365 -out certificate.pem


CONTENT

/pem2ini.sh : Generate an INI file from a PEM certificate file, with information regarding PEM parameters (end date, issuers, subject).
