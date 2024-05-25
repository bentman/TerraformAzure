Set-ExecutionPolicy -Scope Process Bypass -Force

Update-Help -ErrorAction SilentlyContinue -Force -Verbose

# Set Time Zone
$timeZone = 'Pacific Standard Time' # 'Central Standard Time'
Set-TimeZone -Name $timeZone -Confirm:$false

# Install NuGet (no-prompt) & set PSGallery trusted
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

Push-Location ~\Downloads

# From Microsoft.VCLibs redirect
$msftVc_Link = 'https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx'
$msftVc_Name = 'Microsoft.VCLibs.x64.14.00.Desktop.appx'
Invoke-WebRequest -Uri $msftVc_Link -OutFile .\$msftVc_Name -Verbose
Unblock-File .\$msftVc_Name
Add-AppPackage -Path .\$msftVc_Name -Verbose

# From github Microsoft.UI.Xaml https://github.com/microsoft/microsoft-ui-xaml/releases
$MsftUi_Link = 'https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/Microsoft.UI.Xaml.2.8.x64.appx'
$MsftUi_Name = 'Microsoft.UI.Xaml.2.8.x64.appx'
Invoke-WebRequest -Uri $MsftUi_Link -OutFile .\$MsftUi_Name -Verbose
Unblock-File .\$MsftUi_Name
Add-AppPackage -Path .\$MsftUi_Name -Verbose

# MSFT WinGet from winget-cli https://api.github.com/repos/microsoft/winget-cli/releases/latest
$winGet_Repo = "https://api.github.com/repos/microsoft/winget-cli/releases/latest"
$licXml_Link = (Invoke-WebRequest -Uri $winGet_Repo).Content | 
    ConvertFrom-Json |
    Select-Object -ExpandProperty "assets" |
    Where-Object "browser_download_url" -Match '_License1.xml' |
    Select-Object -ExpandProperty "browser_download_url"
$LicXml_Name = '_License1.xml'
Invoke-WebRequest -Uri $licXml_Link -OutFile $LicXml_Name -UseBasicParsing
Unblock-File .\$LicXml_Name
$winGet_Link = (Invoke-WebRequest -Uri $winGet_Repo).Content | 
    ConvertFrom-Json |
    Select-Object -ExpandProperty "assets" |
    Where-Object "browser_download_url" -Match '.msixbundle' |
    Select-Object -ExpandProperty "browser_download_url"
$winGet_Name = "winget.msix"
Invoke-WebRequest -Uri $winGet_Link -OutFile $winGet_Name -UseBasicParsing
Unblock-File .\$winGet_Name
Add-AppxProvisionedPackage -Online -PackagePath .\$winGet_Name -LicensePath .\$LicXml_Name -Verbose

# MSFT Terminal from https://api.github.com/repos/microsoft/terminal/releases/latest
$term_Repo = "https://api.github.com/repos/microsoft/terminal/releases/latest"
$term_Link = (Invoke-WebRequest -Uri $term_Repo).Content | 
    ConvertFrom-Json |
    Select-Object -ExpandProperty "assets" |
    Where-Object "browser_download_url" -NotMatch '.zip' |
    Select-Object -ExpandProperty "browser_download_url"
$term_Name = 'WindowsTerminal.msixbundle'
Invoke-WebRequest -Uri $term_Link -OutFile .\$term_Name -Verbose
Unblock-File .\$term_Name
Add-AppPackage -Path .\$term_Name -Verbose

# WinGet look for pwsh.exe versions (may prompt to accept terms)
winget search Microsoft.PowerShell

# Install pwsh.exe from winget
winget install --id Microsoft.Powershell --source winget

# WinGet look for VS Code versions (it may prompt to accept terms)
winget search Microsoft.VisualStudioCode

# Install VS Code from winget
winget install --id Microsoft.VisualStudioCode --source winget

# WinGet look for AzureCLI (it may prompt to accept terms)
winget search Microsoft.AzureCLI

# Install AzureCLI from winget
winget install --id Microsoft.AzureCLI --source winget

Pop-Location

winget update --all

### Install OpenSSH ###
# Install the OpenSSH Client
Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0
# Install the OpenSSH Server
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
# Start SSH Server Service
Get-Service sshd | Start-Service
# Set SSH Server Service
Set-Service -Name sshd -StartupType 'Automatic'
# Enforce SSH Firewall rule configuration
$sshFw = Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ea 0 | Select-Object Name
if ($null -eq $sshFw) {
    New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
}
if ($false -eq ($sshFw).enabled) {
    Set-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
}

# SSH Default Shell powershell.exe
# New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -PropertyType String -Force

# SSH Default Shell pwsh.exe
New-ItemProperty -Path 'HKLM:\SOFTWARE\OpenSSH' -Name DefaultShell -Value '"C:\Program Files\PowerShell\7\pwsh.exe"' -PropertyType String -Force

# Disable NLA on RDP
Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name 'UserAuthentication' -Value 0
