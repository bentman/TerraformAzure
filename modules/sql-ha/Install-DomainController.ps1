<#
.SYNOPSIS
    This script automates setup and configuration of an Active Directory Domain Services (AD DS) environment on Windows server.
.DESCRIPTION
    The script installs and configures AD DS, DNS, and related features, sets up new AD forest, adjusts firewall settings, and performs other necessary configurations.
.PARAMETER domain_name
    (Mandatory) The fully qualified domain name (FQDN) for new AD forest.
.PARAMETER domain_netbios_name
    (Mandatory) The NetBIOS name for new AD forest.
.PARAMETER safemode_admin_pswd
    (Mandatory) The password for Directory Services Restore Mode (DSRM) administrator.
.EXAMPLE
    .\YourScriptName.ps1 -domain_name "example.com" -domain_netbios_name "EXAMPLE" -safemode_admin_pswd "P@ssw0rd"
.NOTES
    Ensure that script is run with administrative privileges.
#>

[CmdletBinding()]
param ( 
    [Parameter(ValuefromPipeline=$true,Mandatory=$true)] [string]$domain_name,
    [Parameter(ValuefromPipeline=$true,Mandatory=$true)] [string]$domain_netbios_name,
    [Parameter(ValuefromPipeline=$true,Mandatory=$true)] [string]$safemode_admin_pswd
)

# Convert safe mode administrator password to secure string
$safe_admin_pswd = ConvertTo-SecureString $safemode_admin_pswd -AsPlainText -Force
# Create directory for logs if it doesn't already exist
New-Item -Path 'c:\BUILD\Logs\' -ItemType Directory -Force -ea 0
# Start transcript logging
Start-Transcript -Path 'c:\BUILD\Logs\00-Provision.log'
# Set security protocol to TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
# Install NuGet package provider
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
# Set PowerShell Gallery as trusted repository
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
# Install necessary Windows features
Install-WindowsFeature -Name AD-Domain-Services -IncludeAllSubFeature -Verbose
Install-WindowsFeature -Name RSAT-AD-Tools -Verbose
# Import AD DS Deployment module
Import-Module -Name ADDSDeployment -Verbose
# Install DNS server features
Install-WindowsFeature -Name DNS -IncludeAllSubFeature -Verbose
Install-WindowsFeature -Name RSAT-DNS-Server -Verbose
# Import DNS Server module
Import-Module -Name DnsServer -Verbose
# Install new AD DS forest
Install-ADDSForest -DomainName $domain_name -DomainNetBiosName $domain_netbios_name -InstallDns -SafeModeAdministratorPassword $safe_admin_pswd -NoRebootOnCompletion:$true -LogPath 'C:\BUILD\01-DCPromo.log' -Confirm:$false -Force -Verbose
# Disable NLA for Terminal Server (RDP) user authentication setting
Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name 'UserAuthentication' -Value 0
# Disable firewall for Domain profile
Set-NetFirewallProfile -Profile Domain -Enabled:false
# Create firewall rule to allow SSH traffic
New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22 -Profile Any
# Disable Azure Arc Setup feature
Disable-WindowsOptionalFeature -Online -FeatureName AzureArcSetup -NoRestart -LogPath 'c:\BUILD\disableAzureArcSetup.log' -Verbose
# Stop transcript logging
Stop-Transcript
# Exit script (escaping possible errors for automation)
exit 0

