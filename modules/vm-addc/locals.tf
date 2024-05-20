#################### LOCALS ####################
##### locals.tf (vm-addc)
locals {
  # Generate locals for domain join parameters
  split_domain    = split(".", var.domain_name)
  dn_path         = join(",", [for dc in local.split_domain : "DC=${dc}"])
  servers_ou_path = "OU=Servers,${join(",", [for dc in local.split_domain : "DC=${dc}"])}"

  # Generate commands to install DNS and AD Forest
  log_path = "New-Item -Path 'c:\\BUILD\\' -ItemType Directory -Force -ea 0"
  arc_disa = "Disable-WindowsOptionalFeature -Online -FeatureName AzureArcSetup -LogPath 'c:\\BUILD\\disableAzureArcSetup.log' -Verbose"
  pwd_safe = "$safePswd = ConvertTo-SecureString '${var.safemode_admin_pswd}' -AsPlainText -Force"
  ins_adds = "Add-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools"
  ins_dnss = "Install-WindowsFeature DNS -IncludeAllSubFeature -IncludeManagementTools"
  imp_modu = "Import-Module ADDSDeployment, DnsServer"
  dc_promo = "Install-ADDSForest -DomainName '${var.domain_name}' -DomainNetBiosName '${var.domain_netbios_name}' -InstallDns -SafeModeAdministratorPassword $safePswd -NoRebootOnCompletion:$false -LogPath 'C:\\BUILD\\adpromo.log' -Confirm:$false -Force:$true -Verbose"
  exit_hck = "exit 0"

  # PoSh commands list to pass to server over SSH
  powershell_gpmc = "${local.log_path};${local.arc_disa};${local.pwd_safe};${local.ins_adds};${local.ins_dnss};${local.imp_modu};${local.dc_promo};${local.exit_hck};"
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
