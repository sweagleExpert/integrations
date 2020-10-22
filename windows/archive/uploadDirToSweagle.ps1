# This powershell script upload a configuration directory to SWEAGLE platform using REST API
# Version 1.0
# Author : Dimitris Finas
# Inputs required: 1- INPUT DIRECTORY AND 2-  SWEAGLE PATH (values separated by /)
# Inputs optional: 3- FORMAT (format of input files, default is detected by extension
# Inputs optional: 4- EXTENSION (extension to filter files in folder)

param(
    [Parameter(Mandatory=$true)][Alias("dir")][string]$argDir,
    [Parameter(Mandatory=$true)][Alias("sweaglePath")][string]$argNodePath,
    [Parameter(Mandatory=$false)][Alias("ext")][string]$argExtension,
    [Parameter(Mandatory=$false)][Alias("format")][ValidateSet("ini","json","props","properties","xml","yaml","yml")][string]$argFormat
)


# Force execution policy to allow Rescript to run
# Use UNRESTRICTED if you should run this script remotely
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy REMOTESIGNED

If (!(Test-path $argDir)) {
  echo "********** ERROR: Directory $argDir doesn't exist !";
  exit 1
}

If ($PSBoundParameters.ContainsKey('argExtension')) { $files = Get-ChildItem $argDir -Filter *.$argExtension }
else { $files = Get-ChildItem $argDir }

foreach ($f in $files) {
    $filename = [System.IO.Path]::GetFileName($f)
    echo "*******************************"
    echo "*** Uploading ($filename) in SWEAGLE"
    $targetPath = $argNodePath + "/" + $filename
    $inputFile = $f.FullName
    If ($PSBoundParameters.ContainsKey('argFormat')) {
        Invoke-Expression "$PSScriptRoot\uploadFileToSweagle.ps1 -file $inputFile -path $targetPath -format $argFormat"
    } else {
        Invoke-Expression "$PSScriptRoot\uploadFileToSweagle.ps1 -file $inputFile -path $targetPath"
    }
    echo ""
}
