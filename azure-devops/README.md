## SWEAGLE INTEGRATION TO AZURE DEVOPS

# DESCRIPTION

This folder provides examples of configuration to include SWEAGLE into a Azure DevOps pipeline.
SWEAGLE will become the configuration data approval gate after you build your application in DEV and before you deploy it in your Tests and Production environments.
SWEAGLE will also fill the tokens with the values linked to deployment context (targeted environment, release, or component, ...)

# STRATEGIES

3 strategies are available to integrate Sweagle in Azure DevOps pipeline

1. Deploy an Sweagle containerized Azure Agent
  => See folder `/Container_Agent`

2. Install an Sweagle Azure extension
  => See folder `/Sweagle_Extension`

3. Launch REST or SWEAGLE CLI commands from Azure standard command lines tasks

Only the 2 first strategies are presented here as they require additional work.

Please refer to README.md in each folder for more details
