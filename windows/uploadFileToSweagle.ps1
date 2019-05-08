# This powershell script upload configuration to SWEAGLE platform using REST API
# Version 1.1
# Author : Dimitris Finas
# Inputs required: 1- INPUT FILE AND 2- SWEAGLE PATH (values separated by /)
# Inputs optional: FORMAT ("INI","JSON","PROPS","XML","YML")

param(
    [Parameter(Mandatory=$true)][Alias("file")][string]$argFileIn,
    [Parameter(Mandatory=$true)][Alias("path")][string]$argNodePath,
    [Parameter(Mandatory=$false)][Alias("format")][ValidateSet("INI","JSON","PROPS","PROPERTIES","XML","YAML","YML")][string]$argFormat
)


# Force execution policy to allow Rescript to run
# Use UNRESTRICTED if you should run this script remotely
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy REMOTESIGNED

If (!(Test-path $argFileIn)) {
  echo "********** ERROR: Argument $argFileIn doesn't exist !";
  exit 1
}

$dbFile="$PSScriptRoot\db.json"
$API="/api/v1/data/bulk-operations/dataLoader/upload"
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

If ($PSBoundParameters.ContainsKey('argFormat')) {
  switch($argFormat.ToLower())
  {
      "ini"  { $argContentType="text/plain" }
      "json" { $argContentType="application/json" }
      "yaml" { $argContentType="application/x-yaml" }
      "yml"  { $argContentType="application/x-yaml" }
      "xml"  { $argContentType="application/xml" }
      default { $argContentType="text/x-java-properties" }
  }
} else {
  echo "*** Define config format based on file extension"
  $extension = [System.IO.Path]::GetExtension($argFileIn)
  switch($extension.ToLower())
  {
      ".ini"  { $argFormat="ini"; $argContentType="text/plain" }
      ".json" { $argFormat="json"; $argContentType="application/json" }
      ".yaml" { $argFormat="yml"; $argContentType="application/x-yaml" }
      ".yml"  { $argFormat="yml"; $argContentType="application/x-yaml" }
      ".xml"  { $argFormat="xml"; $argContentType="application/xml" }
      default { $argFormat="properties"; $argContentType="text/x-java-properties" }
  }
  echo "File extension detected is: $argFormat"
}

# Build and call the API
# Handle the fact that powershell automatically replaces "," by <space> in input args
$argNodePath = $argNodePath -replace '/', ','
$args="?nodePath=$argNodePath&format=$argFormat&allowDelete=$argDeleteData&onlyParent=$argOnlyParent&autoApprove=$argDcsApprove&storeSnapshotResults=$argSnapshotCreate&validationLevel=$argSnapshotLevel&encoding=$argEncoding"
$url = $sweagleParams.environment.url + $API + $args
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", "Bearer " + $sweagleParams.user.token)
$headers.Add("Accept", "*/*")
#echo $url
#echo $headers

# Call Get Version to debug access to SWEAGLE tenant
#$response = Invoke-RestMethod -Uri "https://testing.sweagle.com/info" -Headers $headers -Method GET -Verbose

try { $response = Invoke-RestMethod -Uri $url -Headers $headers -InFile $argFileIn -ContentType $argContentType -Method POST -Verbose }
catch {
    echo "********** ERROR: API call failed"
    Write-Host "HTTP StatusCode:" $_.Exception.Response.StatusCode.value__
    Write-Host "Exception:" $_.Exception.Message
    exit 1
}

$responseJson = $response | ConvertTo-Json
echo "********** API response: $responseJson"
