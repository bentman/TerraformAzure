[CmdletBinding()]
param ( 
    [Parameter(ValueFromPipeline = $true, Mandatory = $true)] [string]$new_user,
    [Parameter(ValueFromPipeline = $true, Mandatory = $true)] [string]$new_pswd,
    [Parameter(ValueFromPipeline = $true, Mandatory = $true)] [string]$new_tz
)

# Continue on error for automation
$ErrorActionPreference = "SilentlyContinue"

# Reinforce bypass execution policy
Set-ExecutionPolicy -Scope Process Unrestricted -Force

### Create directory for setup if it not exist
New-Item -Path "$env:SystemDrive\BUILD\Content\" -ItemType Directory -Force -ea 0
New-Item -Path "$env:SystemDrive\BUILD\Logs\" -ItemType Directory -Force -ea 0
New-Item -Path "$env:SystemDrive\BUILD\Scripts\" -ItemType Directory -Force -ea 0

# Start transcript logging
Start-transcript -Path 'c:\BUILD\LOGS\00_get_mystuff.log'

# Set Time Zone
Set-TimeZone -Name $new_tz -Confirm:$false

# Create $new_user
New-LocalUser -Name $new_user -Password (ConvertTo-SecureString $new_pswd -AsPlainText -Force) -PasswordNeverExpires -Verbose
# add local user to administrators group
Add-LocalGroupMember -Group Administrators -Member $new_user -Verbose

# create a computer info file
$infoFile = "$env:PUBLIC\Documents\ComputerInfo.txt"
$computerInfo = (Get-ComputerInfo) | Tee-Object -FilePath $infoFile
Out-Host -InputObject " "
Out-Host -InputObject "`nHostname        = $($computerInfo.CsName)"
Out-Host -InputObject "Serial Number   = $($computerInfo.BiosSeralNumber)"
Out-Host -InputObject "Model Name      = $($computerInfo.CsModel)"
Out-Host -InputObject "Manufacturer    = $($computerInfo.CsManufacturer)"
Out-Host -InputObject "BIOS Version    = $($computerInfo.BiosSMBIOSBIOSVersion)"
Out-Host -InputObject "Logical CPU     = $($computerInfo.CsNumberOfLogicalProcessors)"
Out-Host -InputObject "Physical RAM    = $([math]::round($computerInfo.CsPhyicallyInstalledMemory /1MB, 3)) GB"
Out-Host -InputObject "Windows Build   = $($computerInfo.WindowsBuildLabEx)"

### Configure registry keys for IE first-launch completion
# Set IE as already run
New-Item -Path "HKCU:\Software\Microsoft\Internet Explorer\Main" -Force
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Internet Explorer\Main" -Name "RunOnceComplete" -Value 1
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Internet Explorer\Main" -Name "RunOnceHasShown" -Value 1
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Main" -Name "DisableFirstRunCustomize" -Value 1

# Setup NuGet (no prompt) & trust PowerShellGallery
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

# Setup Windows Subsystem for Linux (WSL2)
wsl --install

# Stop transcript logging
Stop-transcript

# Exit script without reporting errors - troubleshooting &/or automation
exit 0


# Run Internet Explorer (or disable first run wizard)
# & "C:\Program Files (x86)\Internet Explorer\iexplore.exe"

<# this is enabled by default for Azure VMs
# Ensure PS remoting is enabled... 
Enable-PSRemoting -SkipNetworkProfileCheck -Verbose
Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Private  -Verbose
Enable-PSRemoting -Verbose
Set-NetFirewallRule -Name WINRM-HTTP-In-TCP -RemoteAddress Any -Enabled True -Verbose
Start-Process -FilePath winrm -ArgumentList "quickconfig", "-q", "-force" -NoNewWindow -Verbose
#>

<# winget is user centric - reun these from $new_user login
# These commands are better run directly from powershell.exe console the first time (not terminal or powershell_ise)
# WinGet look for pwsh.exe versions (prompt to accept terms)
Start-Process -FilePath winget -ArgumentList "search Microsoft.PowerShell"
# Update WinGet (prompt to accept terms)
Start-Process -FilePath winget -ArgumentList "install --id XP89BSK82W9J28", "--source msstore"

# Install pwsh.exe from winget
winget install --id Microsoft.Powershell --source winget

# Set pwsh.exe as your default ssh-shell
New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Program Files\PowerShell\7\pwsh.exe" -PropertyType String -Force

# WinGet look for VS Code versions (it may prompt to accept terms)
winget search Microsoft.VisualStudioCode

# Install VS Code from winget
winget install --id Microsoft.VisualStudioCode --source winget

# WinGet look for AzureCLI (it may prompt to accept terms)
winget search Microsoft.AzureCLI

# Install AzureCLI from winget
winget install --id Microsoft.AzureCLI --source winget

#>

<# winget (if broken) - option 1
$URL = "https://api.github.com/repos/microsoft/winget-cli/releases/latest"
$URL = (Invoke-WebRequest -Uri $URL).Content | ConvertFrom-Json |
    Select-Object -ExpandProperty "assets" |
    Where-Object "browser_download_url" -Match '.msixbundle' |
    Select-Object -ExpandProperty "browser_download_url"
Invoke-WebRequest -Uri $URL -OutFile "winget.msix" -UseBasicParsing # download
Add-AppxPackage -Path "winget.msix" # install

# winget (if broken) - option 2 (if 1 is broken, should update after 'base-install')
$LicXml_Link = 'https://github.com/microsoft/winget-cli/releases/download/v1.6.2771/27abf0d1afe340e7a64fb696056b2672_License1.xml'
$LicXml_Name = '27abf0d1afe340e7a64fb696056b2672_License1.xml'
Invoke-WebRequest -Uri $LicXml_Link -OutFile .\$LicXml_Name
$WinGet_Link = 'https://github.com/microsoft/winget-cli/releases/download/v1.6.2771/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle'
$WinGet_Name = 'Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle'
Invoke-WebRequest -Uri $WinGet_Link -OutFile .\$WinGet_Name
Add-AppxProvisionedPackage -Online -PackagePath .\$WinGet_Name -LicensePath .\$LicXml_Name -Verbose
#>

# WSL2 (if broken)
# https://docs.microsoft.com/en-us/windows/wsl/install
<# 
# Enable-WindowsOptionalFeature -FeatureName 'VirtualMachinePlatform' -All -Online -NoRestart -Verbose
# Enable-WindowsOptionalFeature -FeatureName 'Microsoft-Windows-Subsystem-Linux' -All -Online -NoRestart -Verbose
#>

<# SSH (if broken)
### Install OpenSSH ###
# Install the OpenSSH Client
Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0
# Install the OpenSSH Server
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -PropertyType String -Force
Get-Service sshd | Start-Service
Set-Service -Name sshd -StartupType 'Automatic'
# Confirm the Firewall rule is configured. 
if (-not (Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue | Select-Object Name, Enabled)) {
    Write-Output "Firewall Rule 'OpenSSH-Server-In-TCP' does not exist, creating it..."
    New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
}
else {
    Write-Output "Firewall rule 'OpenSSH-Server-In-TCP' has been created and exists."
}
#>
