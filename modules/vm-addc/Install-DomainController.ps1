[CmdletBinding()]
param ( 
    [Parameter(ValuefromPipeline=$true,Mandatory=$true)] [string]$domain_name,
    [Parameter(ValuefromPipeline=$true,Mandatory=$true)] [string]$domain_netbios_name,
    [Parameter(ValuefromPipeline=$true,Mandatory=$true)] [string]$safemode_admin_pswd
)

$safe_admin_pswd = ConvertTo-SecureString $safemode_admin_pswd -AsPlainText -Force
New-Item -Path 'c:\BUILD\' -ItemType Directory -Force -ea 0
Start-Transcript -Path 'c:\BUILD\00-Provision.log'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-WindowsFeature -Name AD-Domain-Services -IncludeAllSubFeature -Verbose
Install-WindowsFeature -Name RSAT-AD-Tools -Verbose
Import-Module -Name ADDSDeployment -Verbose
Install-WindowsFeature -Name DNS -IncludeAllSubFeature -Verbose
Install-WindowsFeature -Name RSAT-DNS-Server -Verbose
Import-Module -Name DnsServer -Verbose
Install-ADDSForest -DomainName $domain_name -DomainNetBiosName $domain_netbios_name -InstallDns -SafeModeAdministratorPassword $safe_admin_pswd -NoRebootOnCompletion:$true -LogPath 'C:\BUILD\01-DCPromo.log' -Confirm:$false -Force -Verbose
New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22 -Profile Any
New-ItemProperty -Path 'HKLM:\SOFTWARE\OpenSSH' -Name DefaultShell -Value 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -PropertyType String -Force
Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name 'UserAuthentication' -Value 0
Set-NetFirewallProfile -Profile Domain -Enabled:false
Disable-WindowsOptionalFeature -Online -FeatureName AzureArcSetup -NoRestart -LogPath 'c:\BUILD\disableAzureArcSetup.log' -Verbose
Stop-Transcript
exit 0
