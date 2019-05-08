# This powershell script validates a configuration with one SWEAGLE custom validator using REST API
# Version 1.0
# Author : Dimitris Finas
param(
    [Parameter(Mandatory=$true)][Alias("mds")][string]$argMds,
    [Parameter(Mandatory=$true)][Alias("validator")][string]$argValidator
)


# Force execution policy to allow Rescript to run
# Use UNRESTRICTED if you should run this script remotely
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy REMOTESIGNED

# Check if required args are provided
If (!($argMds -And $argValidator)) {
    echo "********** ERROR: NOT ENOUGH ARGUMENTS SUPPLIED"
    echo "********** YOU SHOULD PROVIDE 1-MDS AND 2-VALIDATOR"
    exit 1
}


$dbFile="$PSScriptRoot\db.json"
$API="/api/v1/tenant/metadata-parser/validate"

# Read SWEAGLE Connection parmaeters from db.JSON
If (!(Test-path $dbFile)) {
  echo "********** ERROR: Cannot find SWEAGLE params file ($dbFile)";
  exit 1
}
$sweagleParams = Get-Content $dbFile | ConvertFrom-Json

echo "**********"
echo "*** Call SWEAGLE API to check configuration status for MDS: $argMds and VALIDATOR: $argValidator"
$args = "?mds=$argMds&parser=$argValidator&forIncoming=true"
$url = $sweagleParams.environment.url + $API + $args
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", "Bearer " + $sweagleParams.user.token)
$headers.Add("Accept", "*/*")

try { $response = Invoke-RestMethod -Uri $url -Headers $headers -Method POST }
catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    if ($statusCode -ne 404) {
        echo "********** ERROR: API call failed"
        Write-Host "HTTP StatusCode:" $_.Exception.Response.StatusCode.value__ 
        Write-Host "Exception:" $_.Exception.Message
        exit 1
    } else {
        # This is 404 error, 
        echo "*** No pending MDS found, relaunch API to get last snapshot result instead"
        $args = "?mds=$argMds&parser=$argValidator&forIncoming=false"
        $url = $sweagleParams.environment.url + $API + $args
        try { $response = Invoke-RestMethod -Uri $url -Headers $headers -Method POST }
        catch {
            Write-Host "HTTP StatusCode:" $_.Exception.Response.StatusCode.value__ 
            Write-Host "Exception:" $_.Exception.Message
            exit 1
        }
    }
}

# for debug echo "********** API response: $responseJson"
if ($response.failed) {
    $responseJson = $response | ConvertTo-Json
    echo "********** ERROR: BROKEN configuration data detected, get details of errors and exit"
    echo "********** API response: $responseJson"
    exit 1
} else {
    echo "No errors found for MDS: $argMds"
}
