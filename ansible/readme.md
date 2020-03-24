# SWEAGLE Integration to ANSIBLE

DESCRIPTION

This folder provides examples of script to ANSIBLE facts configuration into SWEAGLE

Use case are multiples :
- validate a configuraiton before deploying it
- discover & retrieve hosts configuration regularly to allow SWEAGLE to control configuration consistency, for example checking the patch level is correct or a package is present before deploying a new release requiring it.

The ansible roles provided here works both with API or CLI (if commands exists) depending on value of parameter "use_cli" available in ./group_vars/all.yml

# PRE-REQUISITES

ANSIBLE v2.5 is required for these scripts to work to allow support of loops



# CONTENT

Each SWEAGLE API/CLI command is available under a specific ./role directory

Examples of playbook to use them are available here:
- ./all.yml : launch all roles in sequence
- ./info.yml : launch only the info role that is used to check connection to your tenant
