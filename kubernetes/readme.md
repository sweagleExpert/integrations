# SWEAGLE Integration to KUBERNETES cluster
DESCRIPTION

This folder provides examples of script to import into SWEAGLE configuration from containers deployed in a Kubernetes cluster.
Use case is to retrieve configuration regularly to allow SWEAGLE to control configuration consistency, for example before deploying a new release.

PRE-REQUISITES

You should use the scripts provided here with the scripts provided under the linux or windows directory.
kubectl api should be configured and worked from the server where this script is launched.

INSTALLATION

1. Put all linux or windows SWEAGLE shell scripts into one folder of the administration server of the kubernetes cluster (where kubectl client is installed)
2. Open the "sweagle.env" script and put your SWEAGLE API token as value for parameter aToken

That's all !

CONTENT

/generateConfigFiles.sh : Use generateConfigFiles.sh to generate all config files from Kubernetes cluster, then use uploadDirToSweagle.sh from linux or windows scripts to import generated files into SWEAGLE
