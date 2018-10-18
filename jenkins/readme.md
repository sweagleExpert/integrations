# Sweagle Integration to Jenkins
DESCRIPTION

This folder provides examples of configuration to include Sweagle into a Jenkins job.
Sweagle will become the configuration data approval gate before you build your application and deploy it to your various environments.
Sweagle will also fill the tokens with the values linked to deployment context (targeted environment, release, or component, ...)

PRE-REQUISITES

You should use the scripts provided here with the scripts provided under the linux or windows directory.

INSTALLATION

1. Put all linux or windows Sweagle shell scripts into one folder of your jenkins job workspace (for example "/sweagle_scripts")
2. Open the "sweagle.env" script and put your sweagle API token as value for parameter aToken
3. In Jenkins, configure your project and add Shell steps in order to use Sweagle scripts. Recommended approach is:
    - First step, upload your config files to Sweagle before build
    - Second step, check configuration status from Sweagle
    - Third step (optional), if you use Sweagle tokens, add a last step to get the configuration files from Sweagle
    - Then, do your build

By default, Sweagle scripts exits with 1 in case of issues, which will fail the Jenkins job.

That's all !

CONTENT
