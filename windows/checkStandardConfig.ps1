# This powershell script validates a config with SWEAGLE standard validators using REST API
# Version 1.0
# Author : Dimitris Finas
param(
    [Parameter(Mandatory=$true)][Alias("mds")][string]$argMds
)


# Force execution policy to allow Rescript to run
# Use UNRESTRICTED if you should run this script remotely
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy REMOTESIGNED

# Check if required args are provided
If (!($argMds)) {
    echo "********** ERROR: NOT ENOUGH ARGUMENTS SUPPLIED"
    echo "********** YOU SHOULD PROVIDE 1-MDS"
    exit 1
}


$dbFile="$PSScriptRoot\db.json"
$API="/api/v1/data/include/validate"
# Set API arguments default values
$forIncoming="true"

# Read SWEAGLE Connection parmaeters from db.JSON
If (!(Test-path $dbFile)) {
  echo "********** ERROR: Cannot find SWEAGLE params file ($dbFile)";
  exit 1
}
$sweagleParams = Get-Content $dbFile | ConvertFrom-Json

# Build and call the API
$args = "?name=$argMds&forIncoming=$forIncoming"
$url = $sweagleParams.environment.url + $API + $args
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", "Bearer " + $sweagleParams.user.token)
$headers.Add("Accept", "*/*")

try { $response = Invoke-RestMethod -Uri $url -Headers $headers -Method GET -Verbose }
catch {
    echo "********** ERROR: API call failed"
    Write-Host "HTTP StatusCode:" $_.Exception.Response.StatusCode.value__
    Write-Host "Exception:" $_.Exception.Message
    exit 1
}

# For debug echo "********** API response: $responseJson"
$nbErrors = $($response.summary.errors)
if ($nbErrors -gt 0) {
    $responseJson = $response | ConvertTo-Json
    echo "********** ERROR: BROKEN configuration data detected, get details of errors and exit"
    echo "********** API response: $responseJson"
    exit 1
} else {
    echo "No errors found for MDS: $argMds"
}
