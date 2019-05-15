# SWEAGLE Integration for Shell SCript

DESCRIPTION

Scripts in this directory helps convert a shell script into a property file, so that you can import it directly in SWEAGLE.
Purpose is to be able to calculate any dynamic values (tokens, like environment specific values) present in the shell script with SWEAGLE, or be able to apply any validation rule to the Script.

Benefits is that all values are stored in central SWEAGLE repository that guarantees secured access and validation of configuration before deployment.

In addition to the scripts in this folder, you should use the shell script exporter to generate the shell with values from SWEAGLE.
This template is located here:
https://github.com/sweagleExpert/templates/blob/master/shellScript.js
