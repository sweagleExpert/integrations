
## Install required modules versions
## Force uninstall of PowerShellGet as it doesn't update without that
## This is required to update PowershellGet (NOT WORKING)
#Install-PackageProvider -Name NuGet -Force
rm -Rf /root/.local/share/powershell/Modules/PowerShellGet/
Install-Module -Name PowerShellGet -RequiredVersion 2.2.4 -Force
Uninstall-Module -Name Az.Accounts -RequiredVersion 1.7.5 -Force
Install-Module -Name Az.Accounts -RequiredVersion 1.9.0 -Force

## Other libraries (NOT NEEDED FOR 3.8)
#Install-module -name PathUtils -Force
#Install-module -name UtilitiesPS -Force
#Install-module -name Utility.PS -Force
#Install-module -name DeploymentModule -Force
#Install-module -name Azure -Force
#Install-module -name AzureDevOpsAPIUtils - Force
#Install-module -name AzureCmdlets -Force
#Install-module -name AzurePipelinesPS -Force
#Install-module -name AzureFileSyncDsc  -Force
#Install-module -name Azure.DevOps  -Force
#Install-module -name AzureDevOpsPS  -Force

## Add compatibility with Azure RM libs (NOT NEEDED FOR 3.8)
#Enable-AzureRmAlias

## Move modules to the expected folder by Azure Pipeline
mkdir -p /usr/share/az_3.8.0
cp -r /root/.local/share/powershell/Modules/* /usr/share/az_3.8.0
rm -Rf /root/.local/share/powershell/Modules

#mkdir -p /usr/local/share/powershell/Modules
#cp -r /root/.local/share/powershell/Modules /usr/local/share/powershell

## create symbolic links to Modules (NOT WORKING)
#mkdir -p /usr/share
#ln -s /root/.local/share/powershell/Modules /usr/share/az_3.8.0
#mkdir -p /usr/local/share/powershell
#ln -s /root/.local/share/powershell/Modules /usr/local/share/powershell

## Add new modules environment path (NEEDED ONLY TO SUPPORT SEVERAL VERSIONS IN PARRALLEL)
#$env:PSModulePath = $env:PSModulePath + "$([System.IO.Path]::PathSeparator)$MyModulePath"
## OR
#$CurrentValue = [Environment]::GetEnvironmentVariable("PSModulePath", "Machine")
#[Environment]::SetEnvironmentVariable("PSModulePath", $CurrentValue + [System.IO.Path]::PathSeparator + "C:\Program Files\Fabrikam\Modules", "Machine")



## List result of installation
#Get-InstalledModule
Get-Module -ListAvailable
