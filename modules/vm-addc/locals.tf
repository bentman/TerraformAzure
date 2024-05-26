#################### LOCALS ####################
### Local variables for vm-addc (domain controller)
# Local variable for the DCPromo script
locals {
  dcPromoScript = "Install-DomainController.ps1"

  # Generate locals for domain join parameters
  split_domain    = split(".", var.domain_name)
  dn_path         = join(",", [for dc in local.split_domain : "DC=${dc}"])
  servers_ou_path = "OU=Servers,${join(",", [for dc in local.split_domain : "DC=${dc}"])}"

  # Generate commands to create new Organization Unit and technical users for SQL installation
  powershell_add_users = [
    "if (!(test-path -Path C:\\BUILD\\)) {New-Item -Path C:\\BUILD\\ -ItemType Directory -Force}",
    "Start-Transcript -Path C:\\BUILD\\transcript-add_users.txt",
    "Test-NetConnection -Computername ${var.domain_name} -Port 9389",
    "Import-Module ActiveDirectory",
    "New-ADOrganizationalUnit -Name 'Servers' -Path '${local.dn_path}' -Description 'Servers OU for new objects'",
    "$secPass = ConvertTo-SecureString '${var.sql_svc_acct_pswd}' -AsPlainText -Force",
    "New-ADUser -Name sqlinstall -GivenName sql -Surname install -UserPrincipalName 'sqlinstall@${var.domain_name}' -SamAccountName sqlinstall -AccountPassword $secPass -Enabled $true",
    "Add-ADGroupMember -Identity 'Domain Admins' -Members sqlinstall",
    "New-ADUser -Name '${var.sql_svc_acct_user}' -GivenName SQL -Surname SERVICE -UserPrincipalName '${var.sql_svc_acct_user}@${var.domain_name}' -SamAccountName '${var.sql_svc_acct_user}' -AccountPassword $secPass -Enabled $true",
    "Stop-Transcript"
  ]


}
