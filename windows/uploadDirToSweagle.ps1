# This powershell script upload a configuration directory to SWEAGLE platform using REST API
# Version 1.0
# Author : Dimitris Finas
# Inputs required: 1- INPUT DIRECTORY AND 2-  SWEAGLE PATH (values separated by ,)
# Inputs optional: 3- FORMAT (format of input files, default is detected by extension
# Inputs optional: 4- EXTENSION (extension to filter files in folder)

param(
    [Parameter(Mandatory=$true)][Alias("dir")][string]$argDir,
    [Parameter(Mandatory=$true)][Alias("sweaglePath")][string]$argNodePath,
    [Parameter(Mandatory=$false)][Alias("ext")][string]$argExtension,
    [Parameter(Mandatory=$false)][Alias("format")][ValidateSet("ini","json","props","properties","xml","yaml","yml")][string]$argFormat
)


# Force execution policy to allow Remote script to run
# Use UNRESTRICTED if you should run this script remotely
try {
    Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy REMOTESIGNED
} catch {
    Write-Warning -Message "*** WARNING: Execution policy is not supported, ignore it"
}

if (!(Test-path $argDir)) {
  Write-Error -Message "********** ERROR: Directory $argDir doesn't exist !";
  exit 1
}

if ($PSBoundParameters.ContainsKey('argExtension')) { $files = Get-ChildItem $argDir -Filter *.$argExtension }
else { $files = Get-ChildItem $argDir }

foreach ($f in $files) {
    $filename = [System.IO.Path]::GetFileName($f)
    Write-Output "*******************************"
    Write-Output "*** Uploading ($filename) in SWEAGLE"
    $targetPath = $argNodePath + "," + $filename
    $inputFile = $f.FullName
    if ($PSBoundParameters.ContainsKey('argFormat')) { $parameters= @{"nodePath"=$targetPath; "format"=$argFormat} }
    else { $parameters= @{"nodePath"=$targetPath} }
    Invoke-Expression "$PSScriptRoot\sweagle-lib.ps1 -operation "upload" -filePath $inputFile -parameters $parameters"
    Write-Output ""
}
