[CmdletBinding()]
param ( 
    [Parameter(ValueFromPipeline = $true, Mandatory = $true)] [string]$domain_name,
    [Parameter(ValueFromPipeline = $true, Mandatory = $true)] [string]$sql_svc_acct_user,
    [Parameter(ValueFromPipeline = $true, Mandatory = $true)] [string]$sql_svc_acct_pswd
)
# Split the domain name into its components
$split_domain = $domain_name.Split(".")
# Construct the DN path from the split domain components
$dn_path = ($split_domain | ForEach-Object { "DC=$_" }) -join ","
# Check if the directory 'C:\BUILD\Logs\' exists, and create it if it does not
if (!(Test-Path -Path 'C:\BUILD\Logs\')) { New-Item -Path 'C:\BUILD\' -ItemType Directory -Force }
# Start a transcript to log all activities to the specified path
Start-Transcript -Path 'C:\BUILD\Logs\transcript-add_users.txt'
# Import the Active Directory module to use AD-related cmdlets
Import-Module ActiveDirectory
# Create a new Organizational Unit (OU) named 'Servers' at the specified DN path
New-ADOrganizationalUnit -Name 'Servers' -Path "$dn_path" -Description 'Servers OU for new objects'
# Create a new AD user for SQL installation with the specified details
New-ADUser -Name 'sqlinstall' -GivenName 'SQL' -Surname 'INSTALL' -UserPrincipalName "sqlinstall@$domain_name" -SamAccountName sqlinstall -AccountPassword (ConvertTo-SecureString "$sql_svc_acct_pswd" -AsPlainText -Force) -Enabled $true
# Add the newly created SQL install user to the 'Domain Admins' group
Add-ADGroupMember -Identity 'Domain Admins' -Members sqlinstall
# Create a new AD user for SQL service account with the specified details
New-ADUser -Name "$sql_svc_acct_user" -GivenName 'SQL' -Surname 'SERVICE' -UserPrincipalName "$sql_svc_acct_user@$domain_name" -SamAccountName $sql_svc_acct_user -AccountPassword (ConvertTo-SecureString "$sql_svc_acct_pswd" -AsPlainText -Force) -Enabled $true
# Stop the transcript
Stop-Transcript
