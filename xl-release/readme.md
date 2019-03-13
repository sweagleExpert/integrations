# SWEAGLE Integration to XL-RELEASE

DESCRIPTION

This folder provides examples of a SWEAGLE plugIns for XL-RELEASE.
Use case is to orchestrate upload, validate, and download of config data with SWEAGLE driven by XL-RELEASE.


PRE-REQUISITES

You should use deploy the scripts provided here as an XL-RELEASE plugin.


INSTALLATION

1. TBD (similar to any XL-RELEASE plugin)

That's all !


CONTENT

/logo/sweagle.png : This is SWEAGLE logo displayed in each SWEAGLE task in XL-RELEASE

/synthetic.xml : This is a description of inputs/outputs required by SWEAGLE scripts

/sweagle/Download.py : Jython script to download a configuration (Metadataset) from SWEAGLE

/sweagle/GetVersion.py : Jython script to test connection to SWEAGLE tenant by requesting the version

/sweagle/Upload.py : Jython script to upload a configuration in a specific path in SWEAGLE

/sweagle/Validate.py : Jython script to validate a configuration in SWEAGLE with specified list of validators
