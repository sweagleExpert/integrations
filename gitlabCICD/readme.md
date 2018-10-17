# Sweagle Integration to GitLab CI/CD
DESCRIPTION

This folder provides examples of configuration to include Sweagle into a GitLab CI/CD.
Sweagle will become the configuration data approval gate after you build your application in DEV and before you deploy it in your Tests and Production environments.
Sweagle will also fill the tokens with the values linked to deployment context (targeted environment, release, or component, ...)

PRE-REQUISITES

You should use the scripts provided here with the scripts provided under the linux or windows directory.

INSTALLATION

1. Put all linux or windows Sweagle shell scripts into one folder of your gitlab repository (for example "/sweagle_scripts")
2. Open file /.gitlab-ci.yml and adapt the 2 tasks "uploadConfiguration" and "deployTestEnvironment" in your own ./gitlab-ci.yml
- For upload task you could take it as a whole, just setting the correct input file/directory,
- For deploy task, just the "before_script" part with parameters should be put in your "before_script" of your own deployment tasks
(only requirement is that these tasks should be in a stage after stage containing "uploadConfiguration")
- Replace all calls using "/sweagle_scripts" path by the path where you put Sweagle scripts

That's all !

CONTENT

/.gitlab-ci.yml         : Sample GitLab CI/CD pipeline file

- Task "uploadConfiguration" is used to upload config files to Sweagle
    - Prérequis: uploadCSSConfiguration utilise une image GitLab Node:6 (besoin de librairie cssjson-cli pour le CSS)
    - Call input:
        - CONFIG_FILE = Config file or directory containing all files to upload to Sweagle
        - FILE_EXTENSION = in case of config directory, you can specify an extension to filter files to upload
                            
- Task "deployTestEnvironment" is used to deploy to your target environment
    - In part, "before_script", call to Sweagle in order to check configuration data that was uploaded before
    - In case the configuration is wrong, Sweagle will return an exit code <> 0 that will freeze the pipeline
    - Pre-requisite: uploadConfiguration task must be finished before confoguration is checked
    (so it should be in a previous stage of gitlab-ci to avoid parallel work)
    - Call input:
        - MDS = Sweagle MDS to check
        - VALIDATORS = Sweagle validator used to check configuration (as many as needed)
