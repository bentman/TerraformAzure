#################### LOCALS ####################
##### locals.tf (vm-addc)
locals {
  # Generate locals for domain join parameters
  split_domain    = split(".", var.domain_name)
  dn_path         = join(",", [for dc in local.split_domain : "DC=${dc}"])
  servers_ou_path = "OU=Servers,${join(",", [for dc in local.split_domain : "DC=${dc}"])}"

  # Generate commands to install DNS and AD Forest
  powershell_gpmc = [
    "if (!(Test-Path -Path C:\\BUILD\\)) {New-Item -Path C:\\BUILD\\ -ItemType Directory -Force}",
    "Start-Transcript -Path C:\\BUILD\\transcript-gpmc.txt",
    "Set-NetFirewallProfile -Enabled False",
    "Install-WindowsFeature AD-Domain-Services -IncludeAllSubFeature -IncludeManagementTools",
    "Install-WindowsFeature DNS -IncludeAllSubFeature -IncludeManagementTools",
    "Import-Module ADDSDeployment, DnsServer",
    "Install-ADDSForest -DomainName ${var.domain_name} -DomainNetbiosName ${var.domain_netbios_name} -NoRebootOnCompletion:$false -Force:$true -SafeModeAdministratorPassword (ConvertTo-SecureString ${var.safemode_admin_pswd} -AsPlainText -Force)",
    "Stop-Transcript"
  ]
}
