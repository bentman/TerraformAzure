#################### LOCALS ####################
##### locals.tf (vm-addc) Windows Server 2022-Datacenter
locals {
  # Generate locals for domain join parameters
  split_domain    = split(".", var.domain_name)
  dn_path         = join(",", [for dc in local.split_domain : "DC=${dc}"])
  servers_ou_path = "OU=Servers,${join(",", [for dc in local.split_domain : "DC=${dc}"])}"

  # Generate PoSh commands to install Active Directory & DNS Features
  log_path    = "New-Item -Path 'c:\\BUILD\\' -ItemType Directory -Force -ea 0"
  prov_log    = "Start-Transcript -Path 'c:\\BUILD\\01-Provision.log'"
  posh_ssh    = "New-ItemProperty -Path 'HKLM:\\SOFTWARE\\OpenSSH' -Name DefaultShell -Value 'C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe' -PropertyType String -Force"
  nugt_sec    = "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12"
  nugt_ins    = "Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force"
  psrepo_1    = "Set-PSRepository -Name PSGallery -InstallationPolicy Trusted"
  add_feat    = "Install-WindowsFeature -Name AD-Domain-Services -IncludeAllSubFeature -Verbose"
  add_rsat    = "Install-WindowsFeature -Name RSAT-AD-Tools -Verbose"
  dns_feat    = "Install-WindowsFeature -Name DNS -IncludeAllSubFeature -Verbose"
  dns_rsat    = "Install-WindowsFeature -Name RSAT-DNS-Server -Verbose"
  arc_disa    = "Disable-WindowsOptionalFeature -Online -FeatureName AzureArcSetup -NoRestart -LogPath 'c:\\BUILD\\disableAzureArcSetup.log' -Verbose"
  stop_log    = "Stop-Transcript"
  exit_hck    = "exit 0"
  restart6    = "Restart-Computer -Delay 15s -Force"

  # PoSh commands over SSH to install Active Directory & DNS Features
  powershell_addsdns = "${local.log_path}; ${local.prov_log}; ${local.posh_ssh}; ${local.nugt_sec}; ${local.nugt_ins}; ${local.psrepo_1}; ${local.add_feat}; ${local.add_rsat}; ${local.dns_feat}; ${local.dns_rsat}; ${local.arc_disa}; ${local.stop_log}; ${local.exit_hck}; ${local.restart6}"
}

/* # Remember - Server 2019 EOL was January 2024 ;-)
##### locals.tf (vm-addc) Windows Server 2019-Datacenter
locals {
  # Generate locals for domain join parameters
  split_domain    = split(".", var.domain_name)
  dn_path         = join(",", [for dc in local.split_domain : "DC=${dc}"])
  servers_ou_path = "OU=Servers,${join(",", [for dc in local.split_domain : "DC=${dc}"])}"

  # Generate PoSh commands to install Active Directory & DNS Features
  log_path = "New-Item -Path 'c:\\BUILD\\' -ItemType Directory -Force -ea 0"
  prov_log = "Start-Transcript -Path 'c:\\BUILD\\01-Provision.log'"
  posh_ssh = "New-ItemProperty -Path 'HKLM:\\SOFTWARE\\OpenSSH' -Name DefaultShell -Value 'C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe' -PropertyType String -Force"
  nugt_sec = "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12"
  nugt_ins = "Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force"
  psrepo_1 = "Set-PSRepository -Name PSGallery -InstallationPolicy Trusted"
  add_feat = "Install-WindowsFeature -Name AD-Domain-Services -IncludeAllSubFeature -Verbose"
  dns_feat = "Install-WindowsFeature -Name DNS -IncludeAllSubFeature -Verbose"
  add_rsat = "Install-WindowsFeature -Name RSAT-AD-Tools -Verbose"
  dns_rsat = "Install-WindowsFeature -Name RSAT-DNS-Server -Verbose"
  add_modu = "Import-Module -Name ADDSDeployment -Verbose"
  dns_modu = "Import-Module -Name DnsServer -Verbose"
  adcpromo = "Install-ADDSForest -DomainName '${var.domain_name}' -DomainNetBiosName '${var.domain_netbios_name}' -InstallDns -SafeModeAdministratorPassword (ConvertTo-SecureString '${var.safemode_admin_pswd}' -AsPlainText -Force) -NoRebootOnCompletion:$true -LogPath 'C:\\BUILD\\adpromo.log' -Confirm:$false -Force -Verbose"
  nla_disa = "Set-ItemProperty 'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\Terminal Server\\WinStations\\RDP-Tcp' -Name 'UserAuthentication' -Value 0"
  stop_log = "Stop-Transcript"
  exit_hck = "exit 0"
  restart6 = "Restart-Computer -Delay 15s -Force"

  # PoSh commands over SSH to install Active Directory & DNS Features
  powershell_addsdns = "${local.log_path};${local.prov_log};${local.posh_ssh};${local.nugt_sec};${local.nugt_ins};${local.psrepo_1};${local.add_feat};${local.dns_feat};${local.add_rsat};${local.dns_rsat};${local.add_modu};${local.dns_modu};${local.adcpromo};${local.nla_disa};${local.stop_log};${local.exit_hck};${local.restart6}"
}

# vm-addc extension to Open SSH
resource "azurerm_virtual_machine_extension" "vm_addc_openssh" {
  name                       = "InstallOpenSSH"
  virtual_machine_id         = azurerm_windows_virtual_machine.vm_addc.id
  publisher                  = "Microsoft.Azure.OpenSSH"
  type                       = "WindowsOpenSSH"
  type_handler_version       = "3.0"
  auto_upgrade_minor_version = true
  depends_on                 = [azurerm_windows_virtual_machine.vm_addc]
  lifecycle {
    ignore_changes = [tags]
  }
}

# PoSh commands over SSH to install Active Directory & DNS Features
resource "azurerm_virtual_machine_extension" "vm_addc_addsdns" {
  name                       = "InstallAddsDns"
  virtual_machine_id         = azurerm_windows_virtual_machine.vm_addc.id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.10"
  auto_upgrade_minor_version = true
  settings = jsonencode({
    "commandToExecute" : "powershell.exe -Command ${local.powershell_addsdns}"
  })
  depends_on = [
    azurerm_windows_virtual_machine.vm_addc,
    azurerm_virtual_machine_extension.vm_addc_openssh
  ]
  lifecycle {
    ignore_changes = [tags, settings]
  }
}

# time delay after addsdns
resource "time_sleep" "vm_addc_addsdns_sleep" {
  create_duration = "120s"
  depends_on      = [azurerm_virtual_machine_extension.vm_addc_addsdns]
}
*/
