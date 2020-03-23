# SWEAGLE Integration to ANSIBLE

DESCRIPTION

This folder provides examples of script to ANSIBLE facts configuration into SWEAGLE

Use case are multiples :
- validate a configuraiton before deploying it
- discover & retrieve hosts configuration regularly to allow SWEAGLE to control configuration consistency, for example checking the patch level is correct or a package is present before deploying a new release requiring it.

PRE-REQUISITES

ANSIBLE v2.5 is required for these scripts to work to allow support of loops



CONTENT

/getFacts.yml : ansible play to export facts into file

/sendFacts.yml : ansible plays to send facts to SWEAGLE
