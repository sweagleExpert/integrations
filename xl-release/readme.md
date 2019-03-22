# SWEAGLE Integration to XL-RELEASE

DESCRIPTION

This folder provides examples of a SWEAGLE plugIns for XL-RELEASE.
Use case is to orchestrate upload, validate, and download any config data with SWEAGLE driven by XL-RELEASE.
As XL-RELEASE is mostly used in conjunction with XL-DEPLOY, we aldo added tasks to be able to upload all dictionnaries from an XL-DEPLOY environment into SWEAGLE, or create or update an existing dictionary into XL-DEPLOY

PRE-REQUISITES

You should deploy the scripts provided here as an XL-RELEASE plugin.

INSTALLATION

1.  it is the same as any XL-RELEASE plugin:
  Upload the jar file from plugIn page, you can also copy the source under /ext directory of your XL-RELEASE server)

That's all !


CONTENT

/bin/xlr-sweagle-plugin.jar : This is the plugin jar file to install in XL-RELEASE

/logo/sweagle.png : This is SWEAGLE logo displayed in each SWEAGLE task in XL-RELEASE

/synthetic.xml : This is a description of inputs/outputs required by SWEAGLE scripts

/sweagle/Download.py : Jython script to download a configuration (Metadataset) from SWEAGLE

/sweagle/DownloadfromXLD.py : Jython script to download all dictionnaries from an XL-DEPLOY server to SWEAGLE
The node path in SWEAGLE will copy the environment path in XL-DEPLOY.

/sweagle/GetVersion.py : Jython script to test connection to SWEAGLE tenant by requesting the version

/sweagle/Upload.py : Jython script to upload a configuration in a specific path in SWEAGLE

/sweagle/UploadToXLD.py : Jython script to upload a configuration from SWEAGLE into XL-DEPLOY
SWEAGLE will update an existing dictionary or create a new one if none exists.

/sweagle/Validate.py : Jython script to validate a configuration in SWEAGLE with specified list of validators
