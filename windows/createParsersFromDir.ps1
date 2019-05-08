# This powershell script create or update a list of parsers and publish them
# Version 1.0
# Author : Dimitris Finas
# Inputs required: 1- INPUT DIRECTORY AND 2- PARSERS TYPE ("EXPORTER","TEMPLATE","VALIDATOR")

param(
    [Parameter(Mandatory=$true)][Alias("path")][string]$argDir,
    [Parameter(Mandatory=$true)][Alias("type")][ValidateSet("EXPORTER","TEMPLATE","VALIDATOR")][string]$argParserType
)


# Force execution policy to allow Rescript to run
# Use UNRESTRICTED if you should run this script remotely
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy REMOTESIGNED

If (!(Test-path $argDir)) {
  echo "********** ERROR: Directory $argDir doesn't exist !";
  exit 1
}

$files = Get-ChildItem $argDir -Filter *.js
foreach ($f in $files) {
    echo "*******************************"
    echo "*** Creating parser for file $f"
    $args = $f.FullName +" "+ $argParserType
    Invoke-Expression "$PSScriptRoot\createParserFromFile.ps1 $args"
    echo ""
}

