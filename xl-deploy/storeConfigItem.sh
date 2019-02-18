#!/usr/bin/env bash
source $(dirname "$0")/xldeploy.env

##########################################################################
#############
#############   CREATE OR UPDATE A CONFIGURATION ITEM IN XL-DEPLOY
#############
############# Inputs: See error message below
############# Output: 0 if no errors, 1 + Details of errors if any
##########################################################################
if [ "$#" -lt "1" ]; then
    echo "********** ERROR: NOT ENOUGH ARGUMENTS SUPPLIED"
    echo "********** YOU SHOULD PROVIDE 1- CONFIG FILENAME TO IMPORT"
    exit 1
fi
argSourceFile=$1

configId=$(cat "$argSourceFile" | jsonValue "id")

# Create config from id
function getConfig {
  local argId=$1
  echo "*** Get configuration item from ID: $argId"
  response=$(curl -s -X GET "$xlDeployURL/repository/ci/$argId" --user "$xlDeployUser:$xlDeployPassword")
  # Check if any error before continue
  if [[ $response == "Repository entity [$argId] not found" ]]; then
    echo -e "\n**********"
    echo "*** Error getting configuration item list: $response"
    exit 1
  fi
}

# Create config from id + file
function createConfig {
  local argId=$1
  local argFile=$2
  echo "*** Create configuration item with ID: $argId"
  # For debug
  #echo "curl -s -X POST '$xlDeployURL/repository/ci/$argId' -H 'Content-Type: application/json' --user '$xlDeployUser:$xlDeployPassword' --data '@$argFile'"
  response=$(curl -s -X POST "$xlDeployURL/repository/ci/$argId" -H "Content-Type: application/json" --user "$xlDeployUser:$xlDeployPassword" --data "@$argFile")
}

# Update config from id + file
function updateConfig {
  local argId=$1
  local argFile=$2
  echo "*** Update configuration item $argId"
  # For debug
  #echo "curl -s -X PUT '$xlDeployURL/repository/ci/$argId' -H 'Content-Type: application/json' --user '$xlDeployUser:$xlDeployPassword' --data '@$argFile'"
  response=$(curl -s -X PUT "$xlDeployURL/repository/ci/$argId" -H "Content-Type: application/json" --user "$xlDeployUser:$xlDeployPassword" --data "@$argFile")
}


echo -e "\n**********"
if [[ ! -z $configId ]]; then
  # Check if error returned because config already exists
  createConfig $configId "$argSourceFile"
  if [[ $response == *"already exists"* ]]; then
    echo "It's already there! Updating it"
    updateConfig $configId "$argSourceFile"
  fi
else
  echo -e "\n**********"
  echo "*** ERROR GETTING CONFIG ID FROM: $argSourceFile"
  exit 1
fi
