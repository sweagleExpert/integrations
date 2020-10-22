# This powershell script download configuration from SWEAGLE platform using REST API
# Version 1.0
# Author : Dimitris Finas
param(
    [Parameter(Mandatory=$true)][Alias("cds")][string]$argCds,
    [Parameter(Mandatory=$true)][Alias("parser")][string]$argParser,
    [Parameter(Mandatory=$false)][Alias("args")][string]$argParserParams,
    [Parameter(Mandatory=$false)][Alias("format")][ValidateSet("INI","JSON","PROPS","XML","YAML")][string]$argFormat = "JSON",
    [Parameter(Mandatory=$false)][Alias("output")][string]$argFileOut,
    [Parameter(Mandatory=$false)][Alias("template")][boolean]$argTemplate = $false
)


# Force execution policy to allow Rescript to run
# Use UNRESTRICTED if you should run this script remotely
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy REMOTESIGNED

# Check if optional args are provided
#If ($PSBoundParameters.ContainsKey('argFileOut')) { }

If (!($argCds -And $argParser)) {
    echo "********** ERROR: NOT ENOUGH ARGUMENTS SUPPLIED"
    echo "********** YOU SHOULD PROVIDE 1- CDS AND 2- PARSER"
    echo "********** (optional) PARSER ARGUMENTS, put args=all_values_separated_by_/"
    echo "********** (optional) FORMAT, put format=JSON (or YAML, or XML, or PROPS, or INI)"
    echo "********** (optional) FILE OUT, put output=complete_filename_with_path"
    echo "********** (optional) TEMPLATE PARSER, put template=true (default is false)"
    exit 1
}


$dbFile="$PSScriptRoot\db.json"
if ($argTemplate) {
    $API="/api/v1/tenant/template-parser/replace"
} else {
    $API="/api/v1/tenant/metadata-parser/parse"
}

# Read SWEAGLE Connection parameters from db.JSON
If (!(Test-path $dbFile)) {
  echo "********** ERROR: Cannot find SWEAGLE params file ($dbFile)";
  exit 1
}
$sweagleParams = Get-Content $dbFile | ConvertFrom-Json

# Build and call the API
# Handle the fact that powershell automatically replaces "," by <space> in input args
$argParserParams = $argParserParams -replace '/', ','
$args="?mds=$argCds&parser=$argParser&format=$argFormat&args=$argParserParams"
$url = $sweagleParams.environment.url + $API + $args
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", "Bearer " + $sweagleParams.user.token)
$headers.Add("Accept", "*/*")

try { $response = Invoke-RestMethod -Uri $url -Headers $headers -Method POST -Verbose }
catch {
    echo "********** ERROR: API call failed"
    Write-Host "HTTP StatusCode:" $_.Exception.Response.StatusCode.value__
    Write-Host "Exception:" $_.Exception.Message
    exit 1
}

if ($argFormat -eq "JSON") { $response = $response | ConvertTo-Json }
if ($argFormat -eq "XML") { $response = $response | ConvertTo-Xml }

If ($PSBoundParameters.ContainsKey('argFileOut')) {
    # There is an output file in args, write it
    New-Item -ItemType file -Force -Path $argFileOut -Value "$response"
} else {
    echo "********** API response:" + $response
}
