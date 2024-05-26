#################### LOCALS ####################
##### locals.tf (vm-sqlha)
locals {
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
    "$secPass = ConvertTo-SecureString '${var.sql_service_account_password}' -AsPlainText -Force",
    "New-ADUser -Name sqlinstall -GivenName sql -Surname install -UserPrincipalName 'sqlinstall@${var.domain_name}' -SamAccountName sqlinstall -AccountPassword $secPass -Enabled $true",
    "Add-ADGroupMember -Identity 'Domain Admins' -Members sqlinstall",
    "New-ADUser -Name '${var.sql_service_account_login}' -GivenName SQL -Surname SERVICE -UserPrincipalName '${var.sql_service_account_login}@${var.domain_name}' -SamAccountName '${var.sql_service_account_login}' -AccountPassword $secPass -Enabled $true",
    "Stop-Transcript"
  ]

  # Generate commands to add install domain account to local administrators group on SQL servers and to sysadmin roles on SQL
  powershell_local_admin = [
    "Start-Transcript -Path C:\\BUILD\\transcript-sql_local_admin.txt",
    "Get-LocalGroup",
    "Test-NetConnection -Computername ${var.domain_name} -Port 9389",
    "Add-LocalGroupMember -Group 'Administrators' -Member 'sqlinstall@${var.domain_name}'",
    "Add-LocalGroupMember -Group 'Administrators' -Member '${var.sql_service_account_login}@${var.domain_name}'",
    "Stop-Transcript"
  ]

  # Generate commands to add install domain account to sysadmin roles on SQL servers
  powershell_sql_sysadmin = [
    "Start-Transcript -Path C:\\BUILD\\transcript-sql_sysadmin.txt",
    "Test-NetConnection -Computername $env:COMPUTERNAME -Port 1433",
    "Invoke-Sqlcmd -ServerInstance 'localhost' -Database 'master' -Query 'CREATE LOGIN [${var.domain_netbios_name}\\sqlinstall] FROM WINDOWS WITH DEFAULT_DATABASE=[master]; EXEC master..sp_addsrvrolemember @loginame = ''${var.domain_netbios_name}\\sqlinstall'', @rolename = ''sysadmin'';' -QueryTimeout '10'",
    "Stop-Transcript"
  ]

  # Generate commands to add special ACL permission to cluster computer object
  powershell_acl_commands = [
    "Start-Transcript -Path C:\\BUILD\\transcript-sql_acl.txt",
    "Test-NetConnection -Computername ${var.domain_name} -Port 9389",
    "$Computer = Get-ADComputer ${var.sqlcluster_name}",
    "$ComputerSID = [System.Security.Principal.SecurityIdentifier] $Computer.SID",
    "$ACL = Get-Acl -Path 'AD:${local.servers_ou_path}'",
    "$Identity = [System.Security.Principal.IdentityReference] $ComputerSID",
    "$ADRight = [System.DirectoryServices.ActiveDirectoryRights] 'GenericAll'",
    "$Type = [System.Security.AccessControl.AccessControlType] 'Allow'",
    "$InheritanceType = [System.DirectoryServices.ActiveDirectorySecurityInheritance] 'All'",
    "$Rule = New-Object System.DirectoryServices.ActiveDirectoryAccessRule($Identity, $ADRight, $Type,  $InheritanceType)",
    "$ACL.AddAccessRule($Rule)",
    "Set-Acl -Path 'AD:${local.servers_ou_path}' -AclObject $ACL",
    "Stop-Transcript"
  ]
}
