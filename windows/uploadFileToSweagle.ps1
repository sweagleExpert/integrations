# This powershell script upload metadata to SWEAGLE platform using REST API
# Version 1.0
# Author : Dimitris Finas
param(
    [string]$argFileIn,
    [string]$argNodePath
)


# Force execution policy to allow Rescript to run
# Use UNRESTRICTED if you should run this script remotely
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy REMOTESIGNED

# Check if required args are provided
If (!($argFileIn -And $argNodePath)) {
    echo "******   This script needs 2 params:"
    echo "1- Input file"
    echo "2- SWEAGLE path to upload in"
    Exit 1
}

If (!(Test-path $argFileIn)) {
  echo "********** ERROR: Argument $argFileIn doesn't exist !";
  exit 1
}

$dbFile="C:\Users\dfina\Documents\Clients\EUROCLEAR\POC\scripts\db.json"

$uploadAPI="/api/v1/data/bulk-operations/dataLoader/upload"
# Set API arguments default values
$argDcsApprove="true"
$argDeleteData="false"
$argEncoding="utf-8"
$argOnlyParent="true"
# don't store snapshot now to be able to validate with custom validators later
$argSnapshotCreate="false"
$argSnapshotLevel="warn"
# Possible values validOnly | warn | error

# Read SWEAGLE Connection parmaeters from db.JSON
If (!(Test-path $dbFile)) {
  echo "********** ERROR: Cannot find SWEAGLE params file ($dbFile)";
  exit 1
}
$sweagleParams = Get-Content $dbFile | ConvertFrom-Json

echo "*** Define config format based on file extension"
$extension = [System.IO.Path]::GetExtension($argFileIn)
switch($extension.ToLower())
{
    ".ini"   { $argFormat="ini"; $argContentType="text/plain" }
    ".json"   { $argFormat="json"; $argContentType="application/json" }
    ".yaml"     { $argFormat="yml"; $argContentType="application/x-yaml" }
    ".yml"     { $argFormat="yml"; $argContentType="application/x-yaml" }
    ".xml"     { $argFormat="xml"; $argContentType="application/xml" }
    default { $argFormat="properties"; $argContentType="text/x-java-properties" }
}
echo "File extension detected is: $argFormat"

# Build and call the API
# Handle the fact that powershell automatically replaces "," by <space> in input args
$argNodePath = $argNodePath -replace ' ', ','
$uploadUrl = $sweagleParams.environment.url + $uploadAPI + "?nodePath=$argNodePath&format=$argFormat&allowDelete=$argDeleteData&onlyParent=$argOnlyParent&autoApprove=$argDcsApprove&storeSnapshotResults=$argSnapshotCreate&validationLevel=$argSnapshotLevel&encoding=$argEncoding" 

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", "Bearer " + $sweagleParams.user.token)
$headers.Add("Accept", "*/*")
#echo $uploadUrl
#echo $headers

# Call Get Version to debug access to SWEAGLE tenant
#$response = Invoke-RestMethod -Uri "https://testing.sweagle.com/info" -Headers $headers -Method GET -Verbose

$response = Invoke-RestMethod -Uri $uploadUrl -Headers $headers -Method POST -InFile $argFileIn -ContentType $argContentType -Verbose
$responseJson = $response | ConvertTo-Json
echo "********** API response: $responseJson"
