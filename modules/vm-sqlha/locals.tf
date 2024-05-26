#################### LOCALS ####################
##### locals.tf (vm-sqlha)
locals {
  # Generate locals for domain join parameters
  split_domain    = split(".", var.domain_name)
  dn_path         = join(",", [for dc in local.split_domain : "DC=${dc}"])
  servers_ou_path = "OU=Servers,${join(",", [for dc in local.split_domain : "DC=${dc}"])}"

  # Generate commands to add install domain account to local administrators group on SQL servers and to sysadmin roles on SQL
  powershell_local_admin = [
    "Start-Transcript -Path C:\\BUILD\\transcript-sql_local_admin.txt",
    "Get-LocalGroup",
    "Test-NetConnection -Computername ${var.domain_name} -Port 9389",
    "Add-LocalGroupMember -Group 'Administrators' -Member 'sqlinstall@${var.domain_name}'",
    "Add-LocalGroupMember -Group 'Administrators' -Member '${var.sql_svc_acct_user}@${var.domain_name}'",
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

/**/
