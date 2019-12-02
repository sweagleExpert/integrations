# SWEAGLE Integration to ANSIBLE

DESCRIPTION

This folder provides examples of script to ANSIBLE facts configuration into SWEAGLE

Use case is to discover & retrieve on site configuration regularly to allow SWEAGLE to control configuration consistency, for example checking the patch level is correct or a package is present before deploying a new release requiring it.

PRE-REQUISITES

The scripts in this directory only does the formatting of data so that you can import it in SWEAGLE.
You should use the scripts provided here with the scripts provided under the linux directory to import configuration.



CONTENT

/getFacts.yml : ansible play to export facts into file

/sendFacts.yml : ansible plays to send facts to SWEAGLE
