# INTRODUCTION
This is Service Now Sweagle extension for Azure DevOps.
You can build, test and publish it from the command line or from an Azure DevOps pipeline.

The initial steps here defined steps required from command line.
Refer to section "Create and Publish from Azure DevOps Pipeline" to do it from an Azure pipeline


# FROM COMMAND LINE

## Getting Started

1. Installation prerequisites

- Install NodeJS 10.x (not latest version as not compatible with Azure Mocha test suite)
  - Go to https://nodejs.org/download/release/v10.22.1/ and select appropriate release

- Install TypeScript Compiler 2.2.0 or greater
  - Go to https://www.npmjs.com/package/typescript

- Install TFS Cross Platform Command Line Interface (tfx-cli)
  - Run `npm i -g tfx-cli`

- Create the directory structure of your project
`|--- README.md    
|--- images                        
    |--- extension-icon.png  
|--- buildAndReleaseTask            // where your task scripts are placed
|--- vss-extension.json             // extension's manifest
`

## Build and Test

Describe and show how to build your code and run the tests.

1. (optional) Prepare the build
- If you start from scracth, in order to create the `tsconfig.json` file.
From your task folder (ex: `/buildAndReleaseTask`), run
`tsc --init`

- Update `tsconfig.json` to put property `"strict": false`

- In `/buildAndReleaseTask` folder, create a `task.json` file from model available here: https://docs.microsoft.com/en-us/azure/devops/extend/develop/add-build-task?view=azure-devops#taskjson

- Update `task.json`, field `id` from GUID generated from site https://www.guidgen.com/

2.	Build your extension
`tsc`

3.	Run your extension
From your task folder (ex: `/buildAndReleaseTask`), run
`node index.js`

By default, extension will run a connection to Sweagle testing tenant with the `/info` api.

4.	Test your extension
From your task folder, run the test suite with
`mocha tests/_suite.js`

## Create Package and Publish it

1. Create a `vss-extension.json` file following instructions at step3 here:
https://docs.microsoft.com/en-us/azure/devops/extend/develop/add-build-task?view=azure-devops#step-3-create-the-extension-manifest-file

2. Create the extension package
From the extension root folder, run:
`tfx extension create --manifest-globs vss-extension.json`

3. Publish the extension
The first time, you need to agree on Microsoft publishing terms.
- Sign in to https://marketplace.visualstudio.com/
- Review the terms and create your publisher account
=> remember the publisher ID as it will be used in `vss-extension.json` publisher field
- From the extension root folder, run:
`tfx extension publish --manifest-globs vss-extension.json`

Optionaly, you can add the option  ` --share-with <yourOrganization>`


# FROM AZURE DEVOPS PIPELINE

## Create and Publish

The first time, you need to agree on Microsoft publishing terms.
- Sign in to https://marketplace.visualstudio.com/
- Review the terms and create your publisher account
=> remember the publisher ID as it will be used in `vss-extension.json` publisher field

- In your Azure DevOps organization settings, extensions list, install the Microsoft "Azure DevOps Extension Tasks" from Microsoft marketplace

- Create an Azure DevOps repository and copy all the files here in it

- Update `task.json`, field `id` from GUID generated from site https://www.guidgen.com/

- Create a personal token to publish extension as defined here: https://docs.microsoft.com/en-us/azure/devops/extend/publish/command-line?view=azure-devops#acquire-a-pat
  - copy it for next step

- Create a service connection to Microsoft Visual Studio MarketPlace
  - use marketplace URL: https://marketplace.visualstudio.com
  - name it `microsoft_visualstudio_marketplace`
  (you can change this name as long as it is consistent with the publish task in your `publish-extension-pipeline.yml` file)
  - use the token defined in previous step

- Create a new pipeline based on file `publish-extension-pipeline.yml`

- Run the pipeline

- You can add and run pipeline `test-extension-pipeline.yml` to test your extension


# COMMONS STEPS FOR COMMAND LINE AND AZURE DEVOPS

## Share your Extension

- Sign in to Microsoft extensions marketplace https://marketplace.visualstudio.com/
- Select your extension and click the "more actions" button (...), select "Share/Unshare" option
- Add the organizations for the one you want to share your extension with

## Use the extension

- Install the extension: Go to your Azure DevOps Organization settings, then click '"extension", then "shared" tab, select and install it
=> If the extension doesn't appear in shared tab, contact your ServiceNow DevOps representative with your Azure DevOps organization name

- Go to any pipeline to check if extension is visible: when editing the pipeline, in the tasks list, search for "sweagle"

- Test the extension: first, use the first operation "Check connection and get info ...", fill your tenant and port information and run the pipeline

## Define as Decorator

- Decorator for all pipelines
cf. https://docs.microsoft.com/en-us/azure/devops/extend/develop/add-pipeline-decorator?view=azure-devops

- filter conditions
You can add conditions to filter pipelines where the decorator will run.
For example, to remove decorator from your publish pipeline, add the lines below at top of your decorator pipeline:
`steps:
- ${{ if ne(Build.DefinitionName, 'Publish Sweagle Extension') }}:
  - task: sweagle@0
`

More details on conditional injection could be found here:
https://docs.microsoft.com/en-us/azure/devops/extend/develop/add-pipeline-decorator?view=azure-devops#conditional-injection


# SOURCES

- Prerequisites installation and create your first extension
https://docs.microsoft.com/en-us/azure/devops/extend/develop/add-build-task?view=azure-devops


# TROUBLESHOOT

- Your updates doesn't seem to be taken into account in your pipeline
  - check which version of the extension is used in your pipeline
  - in the task name, the version used is displayed after `@` character like `task: sweagle@1` for v1.x

- Your mocha test doesn't work and return error like
`Error
      at doRequest (node_modules/azure-pipelines-task-lib/node_modules/sync-request/index.js:27:11)
      at MockTestRunner.downloadFile (node_modules/azure-pipelines-task-lib/mock-test.js:237:22)`

  - Downgrade your nodeJS version to 10.x
  - This is detailed here https://github.com/microsoft/azure-pipelines-task-lib/issues/630

- Your icon is not displayed in Azure task screen
  - copy you icon file as "icon.png" in your task folder
  - this is detailed here https://stackoverflow.com/questions/42050550/why-tfs-build-step-extension-icon-is-missing

- When connecting with Proxy, you got error "got proxy server response: 'HTTP/1.1 407 Proxy Authentication Required"
  - Add a proxy user / password to connect

- Your mocha test can't run from your Azure DevOps publish pipeline
  - This is because Azure sample doesn't include task to install mocha
  - You should add the following task before your test task: TBD
