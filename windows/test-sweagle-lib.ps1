# This powershell script is used to test sweagle-lib script as it test all its functions
# Version 1.O
# Author : Dimitris Finas
# Inputs required: None



Write-Output "*** TESTING OPERATION: info"
. ./sweagle-lib.ps1 -operation "info"

Write-Output "*** TESTING OPERATION: upload"
$parameters= @{"nodePath"="sample,environments,DEV,DEV1"}
$filePath= "./db.json"
. ./sweagle-lib.ps1 -operation "upload" -parameters $parameters -filePath $filePath -Verbose

Write-Output "*** TESTING OPERATION: validate"
$parameters= @{"cds"="sample.DEV1"; "parser"="passwordChecker"}
. ./sweagle-lib.ps1 -operation "validate" -parameters $parameters

Write-Output "*** TESTING OPERATION: validationStatus"
$parameters= @{"cds"="sample.DEV1"; "forIncoming"="false"; "withCustomValidations"="true" }
. ./sweagle-lib.ps1 -operation "validationStatus" -parameters $parameters

Write-Output "*** TESTING OPERATION: snapshot"
$timestamp= Get-Date -Format "yyyyddMM-HH:mm"
$tag= [string]::Concat("PWSH-", $timestamp)
$parameters= @{"cds"="sample.DEV1"; "tag"=$tag; "description"="Snapshot done via powershell"}
. ./sweagle-lib.ps1 -operation "snapshot" -parameters $parameters

Write-Output "*** TESTING OPERATION: export"
$parameters= @{"cds"="sample.DEV1"}
. ./sweagle-lib.ps1 -operation "export" -parameters $parameters

# Remove this exit if you also want to test failed use cases
exit 0

Write-Output "**************************************"
Write-Output "*** FAILED TESTS"
Write-Output "**************************************"

Write-Output "*** TESTING OPERATION: export with failed unknown CDS"
$parameters= @{"cds"="tata"}
. ./sweagle-lib.ps1 -operation "export" -parameters $parameters

Write-Output "*** TESTING OPERATION: validationStatus with failed no pending data"
$parameters= @{"cds"="sample.DEV1"; "forIncoming"="true"}
. ./sweagle-lib.ps1 -operation "validationStatus" -parameters $parameters
