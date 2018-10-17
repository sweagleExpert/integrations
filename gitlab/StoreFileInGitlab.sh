#!/usr/bin/env bash
source $(dirname "$0")/gitlab.env

##########################################################################
#############
#############   STORE A CONFIG FILE INTO GITLAB
#############
############# Inputs:
############# - Source file to store (this config file should be obtained from Sweagle)
############# - Gitlab target folder to store file
############# Source filename is used as target filename in GitLab
#############
############# Output: 0 if no errors, 1 + Details of errors if any
##########################################################################
argSourceFile=$1
argTargetPath=$2
# Example "App1/EnvDEV/release/release2.0"

#filename without path for import
filename=$(basename "$argSourceFile")
fileContent=`cat $argSourceFile`

echo -e "\n**********"
echo "Build gitlab api call"
gitlabFilename=$(rawUrlEncode "$argTargetPath/$filename")
gitlabArgs="branch=$gitlabBranch&author_email=$gitlabAuthorEmail&author_name=$gitlabAuthor&commit_message=config%20provided%20by%20Sweagle"

echo "*** Create or update in git configuration file:" $filename
# For debugging purpose
#echo "(curl -s -G -X POST "$gitlabUrl/$gitlabFilename?$gitlabArgs" --data-urlencode "content=$responseSweagle" -H "$gitlabToken")"

# POST will create the file, while PUT will update an existing one
# First, try to create the file, then, if error, update it instead
responseGit=$(curl -s -G -X POST "$gitlabUrl/$gitlabFilename?$gitlabArgs" --data-urlencode "content=$fileContent" -H "$gitlabToken")
if [[ $responseGit = *"already exists"* ]]; then
  responseGit=$(curl -s -G -X PUT "$gitlabUrl/$gitlabFilename?$gitlabArgs" --data-urlencode "content=$fileContent" -H "$gitlabToken")
fi

echo "GitLab response: $responseGit"
