<#
.SYNOPSIS
    This script automates the setup and configuration of an Active Directory Domain Services (AD DS) environment on a Windows server.
.DESCRIPTION
    The script installs and configures AD DS, DNS, and related features, sets up a new AD forest, adjusts firewall settings, and performs other necessary configurations.
.PARAMETER domain_name
    (Mandatory) The fully qualified domain name (FQDN) for the new AD forest.
.PARAMETER domain_netbios_name
    (Mandatory) The NetBIOS name for the new AD forest.
.PARAMETER safemode_admin_pswd
    (Mandatory) The password for the Directory Services Restore Mode (DSRM) administrator.
.EXAMPLE
    .\YourScriptName.ps1 -domain_name "example.com" -domain_netbios_name "EXAMPLE" -safemode_admin_pswd "P@ssw0rd"
.NOTES
    Ensure that the script is run with administrative privileges.
#>

[CmdletBinding()]
param ( 
    [Parameter(ValuefromPipeline=$true,Mandatory=$true)] [string]$domain_name,
    [Parameter(ValuefromPipeline=$true,Mandatory=$true)] [string]$domain_netbios_name,
    [Parameter(ValuefromPipeline=$true,Mandatory=$true)] [string]$safemode_admin_pswd
)

# Convert the safe mode administrator password to a secure string
$safe_admin_pswd = ConvertTo-SecureString $safemode_admin_pswd -AsPlainText -Force
# Create directory for setup if it not exist
New-Item -Path "$env:SystemDrive\BUILD\Content\" -ItemType Directory -Force -ea 0
New-Item -Path "$env:SystemDrive\BUILD\Logs\" -ItemType Directory -Force -ea 0
New-Item -Path "$env:SystemDrive\BUILD\Scripts\" -ItemType Directory -Force -ea 0
# Start transcript logging
Start-Transcript -Path 'c:\BUILD\Logs\00-Provision.log'
# Set the security protocol to TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
# Install the NuGet package provider
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
# Set PowerShell Gallery as a trusted repository
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
# Install necessary Windows features
Install-WindowsFeature -Name AD-Domain-Services -IncludeAllSubFeature -Verbose
Install-WindowsFeature -Name RSAT-AD-Tools -Verbose
# Import the AD DS Deployment module
Import-Module -Name ADDSDeployment -Verbose
# Install DNS server features
Install-WindowsFeature -Name DNS -IncludeAllSubFeature -Verbose
Install-WindowsFeature -Name RSAT-DNS-Server -Verbose
# Import the DNS Server module
Import-Module -Name DnsServer -Verbose
# Install a new AD DS forest
Install-ADDSForest -DomainName $domain_name -DomainNetBiosName $domain_netbios_name -InstallDns -SafeModeAdministratorPassword $safe_admin_pswd -NoRebootOnCompletion:$true -LogPath 'C:\BUILD\01-DCPromo.log' -Confirm:$false -Force -Verbose
# Disable NLA for Terminal Server (RDP) user authentication setting
Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name 'UserAuthentication' -Value 0
# Disable the firewall for the Domain profile
Set-NetFirewallProfile -Profile Domain -Enabled:false
# Create a firewall rule to allow SSH traffic
New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22 -Profile Any

#####################################################
### Add scripts below here for further automation ###
# Define the script content
$script0Content = @'
### Create directory for setup if it not exist
New-Item -Path "$env:SystemDrive\BUILD\Content\" -ItemType Directory -Force -ea 0
New-Item -Path "$env:SystemDrive\BUILD\Logs\" -ItemType Directory -Force -ea 0
New-Item -Path "$env:SystemDrive\BUILD\Scripts\" -ItemType Directory -Force -ea 0
### Start transcript logging
Start-Transcript -Path "$env:SystemDrive\BUILD\Logs\01-DevToMyWinServer.log"
### Configure registry keys for IE first-launch completion
# Disable IE Welcome Page
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Main" -Name "DisableFirstRunCustomize" -Value 1
# Set IE as already run
New-Item -Path "HKCU:\Software\Microsoft\Internet Explorer\Main" -Force
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Internet Explorer\Main" -Name "RunOnceComplete" -Value 1
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Internet Explorer\Main" -Name "RunOnceHasShown" -Value 1
# Repeat for the default user profile to cover all users
New-Item -Path "HKU\.DEFAULT\Software\Microsoft\Internet Explorer\Main" -Force
Set-ItemProperty -Path "HKU\.DEFAULT\Software\Microsoft\Internet Explorer\Main" -Name "RunOnceComplete" -Value 1
Set-ItemProperty -Path "HKU\.DEFAULT\Software\Microsoft\Internet Explorer\Main" -Name "RunOnceHasShown" -Value 1
### Install NuGet (no-prompt) & set PSGallery trusted
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
### Change Directory to Content location for downloads
Push-Location "$env:SystemDrive\BUILD\Content\"
### Get Microsoft.VCLibs from redirect
$MsftVc_Link = 'https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx'
$MsftVc_Name = 'Microsoft.VCLibs.x64.14.00.Desktop.appx'
Invoke-WebRequest -Uri $MsftVc_Link -OutFile .\$MsftVc_Name -UseBasicParsing -Verbose
Add-AppPackage -Path .\$MsftVc_Name -Verbose
### Get Microsoft.UI.Xaml from github https://github.com/microsoft/microsoft-ui-xaml/releases
$MsftUi_Link = 'https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/Microsoft.UI.Xaml.2.8.x64.appx'
$MsftUi_Name = 'Microsoft.UI.Xaml.2.8.x64.appx'
Invoke-WebRequest -Uri $MsftUi_Link -OutFile .\$MsftUi_Name -UseBasicParsing -Verbose
Add-AppPackage -Path .\$MsftUi_Name -Verbose
### Get winget-cli from MSFT repo https://api.github.com/repos/microsoft/winget-cli/releases/latest
$winGet_Repo = "https://api.github.com/repos/microsoft/winget-cli/releases/latest"
$licXml_Link = (Invoke-WebRequest -Uri $winGet_Repo -UseBasicParsing).Content | 
    ConvertFrom-Json |
    Select-Object -ExpandProperty "assets" |
    Where-Object "browser_download_url" -Match '_License1.xml' |
    Select-Object -ExpandProperty "browser_download_url"
$LicXml_Name = '_License1.xml'
Invoke-WebRequest -Uri $licXml_Link -OutFile $LicXml_Name -UseBasicParsing
Unblock-File .\$LicXml_Name
$winGet_Link = (Invoke-WebRequest -Uri $winGet_Repo -UseBasicParsing).Content | 
    ConvertFrom-Json |
    Select-Object -ExpandProperty "assets" |
    Where-Object "browser_download_url" -Match '.msixbundle' |
    Select-Object -ExpandProperty "browser_download_url"
$winGet_Name = "winget.msixbundle"
Invoke-WebRequest -Uri $winGet_Link -OutFile $winGet_Name -UseBasicParsing
Unblock-File .\$winGet_Name
Add-AppxProvisionedPackage -Online -PackagePath .\$winGet_Name -LicensePath .\$LicXml_Name -Verbose
### Get Terminal from MSFT repo https://api.github.com/repos/microsoft/terminal/releases/latest
$term_Repo = "https://api.github.com/repos/microsoft/terminal/releases/latest"
$term_Link = (Invoke-WebRequest -Uri $term_Repo -UseBasicParsing).Content | 
    ConvertFrom-Json |
    Select-Object -ExpandProperty "assets" |
    Where-Object "browser_download_url" -NotMatch '.zip' |
    Select-Object -ExpandProperty "browser_download_url"
$term_Name = 'WindowsTerminal.msixbundle'
Invoke-WebRequest -Uri $term_Link -OutFile .\$term_Name -UseBasicParsing -Verbose
Unblock-File .\$term_Name
Add-AppPackage -Path .\$term_Name -Verbose
### Revert Directory from Content location
Pop-Location
### Stop transcript logging
Stop-Transcript
### Exit the script (escaping possible errors for automation)
exit 0
'@
# Define the file path
$script0Path = "$env:SystemDrive\Add-DevToMyWinServer.ps1"
# Create the directory for the script if it doesn't exist
New-Item -Path (Split-Path -Path $script0Path) -ItemType Directory -Force -ea 0
# Write the content to the file
Set-Content -Path $script0Path -Value $script0Content
### Add scripts above here for further automation ###
#####################################################

# Disable the Azure Arc Setup feature
Disable-WindowsOptionalFeature -Online -FeatureName AzureArcSetup -NoRestart -LogPath 'c:\BUILD\disableAzureArcSetup.log' -Verbose
# Stop transcript logging
Stop-Transcript
# Exit the script (escaping possible errors for automation)
exit 0
