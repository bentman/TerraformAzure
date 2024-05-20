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
    "Add-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools",
    "Install-WindowsFeature DNS -IncludeAllSubFeature -IncludeManagementTools",
    "Import-Module ADDSDeployment, DnsServer",
    "Install-ADDSForest -DomainName '${var.domain_name}' -DomainNetBiosName '${var.domain_netbios_name}' -InstallDns -SafeModeAdministratorPassword $safePswd -NoRebootOnCompletion:$false -LogPath 'C:\\BUILD\\adpromo.log' confirm:$false -Force:$true -Verbose",
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
