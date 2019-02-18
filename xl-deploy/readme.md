# SWEAGLE Integration to XL-DEPLOY

DESCRIPTION

This folder provides examples of script to integrate SWEAGLE with XL-DEPLOY.
Use case could be of two kinds:
1. If XL-DEPLOY dictionary is the source of truth for configuration, than get configuration items regularly from XL-DEPLOY dictionary and validates it with SWEAGLE before deployment occurs
2. If configuration source of truth is outside XL-DEPLOY (for example in developers git), get configuration in SWEAGLE, validates it, then store it in XL-DEPLOY for deployment


PRE-REQUISITES

You should use the scripts provided here with the scripts provided under the linux or windows directory.


INSTALLATION

1. Open the "xldeploy.env" script and put your XL-DEPLOY parameters in it (URL, user/password, and script path)

That's all !


CONTENT

/getConfigByID.sh : Use to get configuration item from XL-DEPLOY dictionary for use case 1

/storeConfigItem.sh : Use to create or update a configuration item in XL-DEPLOY dictionary for use case 2.
Source file for configuration item should be in XL-DEPLOY JSON format.
