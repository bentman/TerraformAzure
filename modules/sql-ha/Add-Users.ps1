[CmdletBinding()]
param ( 
    [Parameter(ValueFromPipeline = $true, Mandatory = $true)] [string]$domain_name,
    [Parameter(ValueFromPipeline = $true, Mandatory = $true)] [string]$sql_svc_acct_user,
    [Parameter(ValueFromPipeline = $true, Mandatory = $true)] [string]$sql_svc_acct_pswd
)

# Split domain name into its components
$split_domain = $domain_name.Split(".")
# Construct DN path from split domain components
$dn_path = ($split_domain | ForEach-Object { "DC=$_" }) -join ","

# Check if directory 'C:\BUILD\Logs\' exists, and create it if it does not
if (!(Test-Path -Path 'C:\BUILD\Logs\')) { 
    New-Item -Path 'C:\BUILD\Logs\' -ItemType Directory -Force 
}

# Start transcript to log all activities to specified path
Start-Transcript -Path 'C:\BUILD\Logs\transcript-add_users.txt'

# Import Active Directory module to use AD-related cmdlets
Import-Module ActiveDirectory

# Create new Organizational Unit (OU) named 'Servers' at specified DN path if not exist
if (-not (Get-ADOrganizationalUnit -Filter "Name -eq 'Servers'")) {
    New-ADOrganizationalUnit -Name 'Servers' -Path "$dn_path" -Description 'OU for Server objects' -Verbose
}

# Create new AD user for SQL installation with specified details
New-ADUser `
    -SamAccountName 'sqlinstall' `
    -Name 'sqlinstall' `
    -GivenName 'SQL' `
    -Surname 'INSTALL' `
    -UserPrincipalName "sqlinstall@$domain_name" `
    -AccountPassword (ConvertTo-SecureString "$sql_svc_acct_pswd" -AsPlainText -Force) `
    -Enabled $true `
    -Verbose

# Set password options and other properties
Set-ADUser -Identity 'sqlinstall' `
    -PasswordNeverExpires $true `
    -ChangePasswordAtLogon $false `
    -CannotChangePassword $true `
    -Description 'SQL Install Account' `
    -DisplayName 'SQL Install Account'

# Add newly created SQL install user to 'Domain Admins' group (more permission than required)
Add-ADGroupMember -Identity "Domain Admins" -Members 'sqlinstall'

# Create new Organizational Unit (OU) named 'Service_Accounts' at specified DN path if not exist
if (-not (Get-ADOrganizationalUnit -Filter "Name -eq 'Service_Accounts'")) {
    New-ADOrganizationalUnit -Name 'Service_Accounts' -Path "$dn_path" -Description 'OU for Service_Accounts' -Verbose
}

# Create new AD user for SQL service account with specified details
New-ADUser `
    -SamAccountName $sql_svc_acct_user `
    -Name "$sql_svc_acct_user" `
    -GivenName 'SQL' `
    -Surname 'SERVICE' `
    -UserPrincipalName "$sql_svc_acct_user@$domain_name" `
    -AccountPassword (ConvertTo-SecureString "$sql_svc_acct_pswd" -AsPlainText -Force) `
    -Path "OU=Service_Accounts,$dn_path" `
    -Enabled $true `
    -Verbose

# Set password options and other properties
Set-ADUser -Identity $sql_svc_acct_user `
    -PasswordNeverExpires $true `
    -ChangePasswordAtLogon $false `
    -CannotChangePassword $true `
    -Description 'SQL Service Account' `
    -DisplayName 'SQL Service Account'

# Stop transcript
Stop-Transcript
