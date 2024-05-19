#################### LOCALS ####################
##### locals.tf (vm-addc)
locals {
  # Generate locals for domain join parameters
  split_domain    = split(".", var.domain_name)
  dn_path         = join(",", [for dc in local.split_domain : "DC=${dc}"])
  servers_ou_path = "OU=Servers,${join(",", [for dc in local.split_domain : "DC=${dc}"])}"

  # Generate commands to install DNS and AD Forest
  powershell_dcpromo = [
    "$safePswd = ConvertTo-SecureString '${var.safemode_admin_pswd}' -AsPlainText -Force",
    "$dnsPswd = ConvertTo-SecureString '${var.vm_localadmin_pswd}' -AsPlainText -Force",
    "$dnsCred = New-Object System.Management.Automation.PSCredential ('${var.vm_localadmin_user}', $dnsPswd)",
    "Add-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools -LogPath C:\\BUILD\\AD-Domain-Services.log",
    "Install-WindowsFeature DNS -IncludeAllSubFeature -IncludeManagementTools  -LogPath C:\\BUILD\\ADDS-DNS.log",
    "Import-Module ADDSDeployment, DnsServer",
    "Install-ADDSForest -DomainName '${var.domain_name}' -InstallDns -Credential $dnsCred -SafeModeAdministratorPassword $safePswd -NoRebootOnCompletion:$false -LogPath C:\\BUILD\\adpromo.log -Force:$true",
    "exit 0",
  ]
}
/*
locals {
  pswd_cmd  = "$password = ConvertTo-SecureString ${var.admin_password} -AsPlainText -Force"
  cred_cmd  = "$credentials = Get-Credential ${var.domainAdminUsername}"
  adpro_cmd = "Add-WindowsFeature -name ad-domain-services -IncludeManagementTools"
  adcfg_cmd = "Install-ADDSDomainController -DomainName ${var.active_directory_domain} -InstallDns -Credential $credentials -SafeModeAdministratorPassword $password -Force:$true"
  shut_hck  = "shutdown -r -t 10"
  exit_hck  = "exit 0"
}
powershell_dcpromo = " ${local.path_log};${local.file_log};${local.firewall};${local.pswd_cmd};${local.cred_cmd}; ${local.adins_cmd}; ${local.adpro_cmd}; ${local.adcfg_cmd}; ${local.shut_hck}; ${local.exit_hck}"
*/
