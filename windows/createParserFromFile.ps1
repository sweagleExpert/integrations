# This powershell script create or update a parser and publish it
# Version 1.0
# Author : Dimitris Finas
# Inputs required: 1- INPUT FILE AND 2- PARSER TYPE ("EXPORTER","TEMPLATE","VALIDATOR")

param(
    [Parameter(Mandatory=$true)][Alias("file")][string]$argFileIn,
    [Parameter(Mandatory=$true)][Alias("type")][ValidateSet("EXPORTER","TEMPLATE","VALIDATOR")][string]$argParserType
)


# Force execution policy to allow Rescript to run
# Use UNRESTRICTED if you should run this script remotely
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy REMOTESIGNED

If (!(Test-path $argFileIn)) {
  echo "********** ERROR: Argument $argFileIn doesn't exist !";
  exit 1
} else {
  # Get file content and Script description
  $parserName = [io.path]::GetFileNameWithoutExtension($argFileIn)
  $fileContent = Get-Content -Raw $argFileIn
  $description = Get-Content $argFileIn -First 1
  if ($description -match "// description: (?<description>.*)") { $description = $matches['description'] }
  else { $description = $parserName }
}

$dbFile="$PSScriptRoot\db.json"
if ($argParserType -eq "TEMPLATE") { $API="/api/v1/tenant/template-parser" }
else { $API="/api/v1/tenant/metadata-parser" } 

# Read SWEAGLE connection parameters from db.JSON
If (!(Test-path $dbFile)) {
  echo "********** ERROR: Cannot find SWEAGLE params file ($dbFile)";
  exit 1
}
$sweagleParams = Get-Content $dbFile | ConvertFrom-Json

# Set API common parameters
if ($argParserType -eq "TEMPLATE") { $API="/api/v1/tenant/template-parser" }
else { $API="/api/v1/tenant/metadata-parser" }
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", "Bearer " + $sweagleParams.user.token)
$headers.Add("Accept", "*/*")
$argContentType = "application/javascript"


#############################################################################
# Create parser from file and put new created Id in variable parserId
#############################################################################
function createParser {
  Param ([string]$argName,[string]$argDescription,[string]$argScript)

  if ($argParserType -eq "TEMPLATE") {
    $args="?name=$argName&description="+ [System.Uri]::EscapeDataString($argDescription) +"&template="+[System.Uri]::EscapeDataString($argScript)
  } else {
    $args="?name=$argName&parserType=$argParserType&errorDescriptionDraft=error+in+parser+$argName&description="+ [System.Uri]::EscapeDataString($argDescription) +"&scriptDraft="+[System.Uri]::EscapeDataString($argScript)
  }
  $url = $sweagleParams.environment.url + $API + $args
  try { $response = Invoke-RestMethod -Uri $url -Headers $headers -ContentType $argContentType -Method POST }
  catch {
    echo "********** ERROR: API call failed"
    Write-Host "HTTP StatusCode:" $_.Exception.Response.StatusCode.value__
    Write-Host "Exception:" $_.Exception.Message
    exit 1
  }
 # Everything goes well, returns ID of parser created
 return $response.id
}


#############################################################################
# Create parser from file and put new created Id in variable parserId
#############################################################################
function getParsers {

  $url = $sweagleParams.environment.url + $API
  try { $response = Invoke-RestMethod -Uri $url -Headers $headers -ContentType $argContentType -Method GET }
  catch {
    echo "********** ERROR: API call failed"
    Write-Host "HTTP StatusCode:" $_.Exception.Response.StatusCode.value__
    Write-Host "Exception:" $_.Exception.Message
    exit 1
  }
 # Everything goes well, returns ID of parser created
 return $response
}


#############################################################################
# Publish parser from ID and content for TEMPLATE
#############################################################################
function publishParser {
  Param ([int]$argId,[string]$argScript)

  if ($argParserType -eq "TEMPLATE") {
    $args="/"+ $argId +"/publish?template="+ [System.Uri]::EscapeDataString($argScript)
  } else {
    $args="/"+ $argId +"/publish"
  }
  $url = $sweagleParams.environment.url + $API + $args
  echo $url
  try { $response = Invoke-RestMethod -Uri $url -Headers $headers -ContentType $argContentType -Method POST }
  catch {
    echo "********** ERROR: API call failed"
    Write-Host "HTTP StatusCode:" $_.Exception.Response.StatusCode.value__
    Write-Host "Exception:" $_.Exception.Message
    exit 1
  }
 #$responseJson = $response | ConvertTo-Json
 #echo "********** API response: $responseJson"
}


#############################################################################
# Update parser from ID and content
#############################################################################
function updateParser {
  Param ([int]$argId,[string]$argDescription,[string]$argScript)

  if ($argParserType -eq "TEMPLATE") {
    $args="/"+ $argId +"?description="+ [System.Uri]::EscapeDataString($argDescription) +"&template="+[System.Uri]::EscapeDataString($argScript)
  } else {
    $args="/"+ $argId +"?description="+ [System.Uri]::EscapeDataString($argDescription) +"&scriptDraft="+[System.Uri]::EscapeDataString($argScript)
  }
  $url = $sweagleParams.environment.url + $API + $args
  try { $response = Invoke-RestMethod -Uri $url -Headers $headers -ContentType $argContentType -Method POST }
  catch {
    echo "********** ERROR: API call failed"
    Write-Host "HTTP StatusCode:" $_.Exception.Response.StatusCode.value__
    Write-Host "Exception:" $_.Exception.Message
    exit 1
  }
}


echo "**********"
$parserList = getParsers

# check if parser already exists
$parser = $parserList._entities | where { $_.name -eq $parserName }
if ($parser) {
    echo "*** Existing parser with name ($parserName), update it"
    $parserId = $parser.id
    updateParser $parserId "$description" "$fileContent"
} else {
    echo "*** No existing parser with name ($parserName), create it"
    $parserId = createParser "$parserName" "$description" "$fileContent"
}

echo "*** Publish parser with id ($parserId)"
publishParser $parserId "$fileContent"
