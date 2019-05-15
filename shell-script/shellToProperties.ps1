# This powershell script transform a shell script into a property file so that you can import it in SWEAGLE
# Version 1.1
# Author : Dimitris Finas
# Inputs required: 1- INPUT FILE
param(
    [Parameter(Mandatory=$true)][Alias("file")][string]$argFileIn
)

$directory = (get-item $argFileIn).DirectoryName
$filename = (get-item $argFileIn).BaseName
#$extension = (get-item $argFileIn).Extension
#$fullname = [System.IO.Path]::GetFileName($argFileIn)
$tempFile = "$argFileIn.tmp"
$outputFile = $directory + "\" + $filename + ".properties"

# Remove blank lines
$input = Get-Content -Raw $argFileIn
$input = $input -replace '(?m)^\s*\r?\n',''
# Write result to temp file
Set-Content -Path $tempFile -Force -Value $input

# Transform it into property file
Get-Content $tempFile | ForEach-Object { "LINE{0:0000}={1}" -f ($index++).ToString("0000"), $_} | Set-Content -Path $outputFile -Force
remove-item -Force $tempFile
