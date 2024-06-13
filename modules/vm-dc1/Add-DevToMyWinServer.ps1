# Install NuGet (no-prompt) & set PSGallery trusted
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
# Create directory for setup if it not exist
New-Item -Path "$env:SystemDrive\BUILD\Content\" -ItemType Directory -Force -ea 0
New-Item -Path "$env:SystemDrive\BUILD\Logs\" -ItemType Directory -Force -ea 0
New-Item -Path "$env:SystemDrive\BUILD\Scripts\" -ItemType Directory -Force -ea 0
# Start transcript logging
Start-Transcript -Path "$env:SystemDrive\BUILD\Logs\01-DevToMyWinServer.log"
# Change Directory to Content location for downloads
Push-Location "$env:SystemDrive\BUILD\Content\"
# Get Microsoft.VCLibs from redirect
$MsftVc_Link = 'https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx'
$MsftVc_Name = 'Microsoft.VCLibs.x64.14.00.Desktop.appx'
Invoke-WebRequest -Uri $MsftVc_Link -OutFile .\$MsftVc_Name -Verbose
Add-AppPackage -Path .\$MsftVc_Name -Verbose
# Get Microsoft.UI.Xaml from github https://github.com/microsoft/microsoft-ui-xaml/releases
$MsftUi_Link = 'https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/Microsoft.UI.Xaml.2.8.x64.appx'
$MsftUi_Name = 'Microsoft.UI.Xaml.2.8.x64.appx'
Invoke-WebRequest -Uri $MsftUi_Link -OutFile .\$MsftUi_Name -Verbose
Add-AppPackage -Path .\$MsftUi_Name -Verbose
# Get winget-cli from MSFT repo https://api.github.com/repos/microsoft/winget-cli/releases/latest
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
$winGet_Name = "winget.msixbundle"
Invoke-WebRequest -Uri $winGet_Link -OutFile $winGet_Name -UseBasicParsing
Unblock-File .\$winGet_Name
Add-AppxProvisionedPackage -Online -PackagePath .\$winGet_Name -LicensePath .\$LicXml_Name -Verbose
# Get Terminal from MSFT repo https://api.github.com/repos/microsoft/terminal/releases/latest
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
# Revert Directory from Content location
Pop-Location
# Stop transcript logging
Stop-Transcript
# Exit the script (escaping possible errors for automation)
exit 0
