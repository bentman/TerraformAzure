#################### vm-addc ####################
########## vm-addc variables 
variable "vm_addc_hostname" {
  type        = string
  default     = "addc-0150"
  description = "Computername for domain controller"
}

variable "vm_addc_size" {
  type        = string
  default     = "Standard_D2s_v3"
  description = "The size of the Virtual Machine(s) type."
}

variable "domain_name" {
  type        = string
  default     = "mylab.mytenant.onmicrosoft.com"
  description = "domain name"
}

variable "domain_netbios_name" {
  type        = string
  default     = "MYLAB"
  description = "domain netbios name"
}

variable "domain_admin_user" {
  type        = string
  default     = "domainadmin"
  description = "admin username"
  sensitive   = true
}

variable "domain_admin_pswd" {
  type        = string
  default     = "P@ssw0rd!"
  description = "domainadmin password"
  sensitive   = true
}

variable "safemode_admin_pswd" {
  type        = string
  default     = "P@ssw0rd!"
  description = "domain safemode password"
  sensitive   = true
}

########## vm-addc
# vm-addc Publip IP with internet DNS hostname
resource "azurerm_public_ip" "vm_addc_pip" {
  name                = "vm-addc-pip"
  location            = azurerm_resource_group.mylab.location
  resource_group_name = azurerm_resource_group.mylab.name
  domain_name_label   = var.vm_addc_hostname
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
  lifecycle {
    ignore_changes = [tags]
  }
}

# vm-addc primary NIC 
resource "azurerm_network_interface" "vm_addc_nic" {
  name                          = "vm-addc-nic"
  location                      = azurerm_resource_group.mylab.location
  resource_group_name           = azurerm_resource_group.mylab.name
  enable_accelerated_networking = true
  tags                          = var.tags
  ip_configuration {
    name                          = "vm-addc-ip"
    subnet_id                     = azurerm_subnet.snet_0128_server.id
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost("10.0.0.128/25", 22) // "10.0.0.150"
    primary                       = true
    public_ip_address_id          = azurerm_public_ip.vm_addc_pip.id
  }
  lifecycle {
    ignore_changes = [tags]
  }
}

########## vm-addc (domain controller)
resource "azurerm_windows_virtual_machine" "vm_addc" {
  name                = "vm-addc"
  location            = azurerm_resource_group.mylab.location
  resource_group_name = azurerm_resource_group.mylab.name
  size                = var.vm_addc_size
  computer_name       = var.vm_addc_hostname
  admin_username      = var.domain_admin_user
  admin_password      = var.domain_admin_pswd
  license_type        = "Windows_Server"
  tags                = var.tags
  os_disk {
    name                 = "vm-addc-dsk0os"
    caching              = "ReadWrite"
    disk_size_gb         = "127"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
  winrm_listener {
    protocol = "Http"
  }
  network_interface_ids = [
    azurerm_network_interface.vm_addc_nic.id,
  ]
  lifecycle {
    ignore_changes = [tags]
  }
}

# vm-addc associate NIC with NSG
resource "azurerm_network_interface_security_group_association" "vm_addc_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.vm_addc_nic.id
  network_security_group_id = azurerm_network_security_group.vnet_nsg.id
}

# vm-addc AUTOSHUTDOWN
resource "azurerm_dev_test_global_vm_shutdown_schedule" "vm_addc_shutown" {
  virtual_machine_id    = azurerm_windows_virtual_machine.vm_addc.id
  location              = azurerm_resource_group.mylab.location
  enabled               = true
  daily_recurrence_time = var.vm_shutdown_hhmm
  timezone              = var.vm_shutdown_tz
  notification_settings {
    enabled = false
  }
}

# vm-addc extension to Open SSH
resource "azurerm_virtual_machine_extension" "vm_addc_openssh" {
  name                       = "InstallOpenSSH"
  virtual_machine_id         = azurerm_windows_virtual_machine.vm_addc.id
  publisher                  = "Microsoft.Azure.OpenSSH"
  type                       = "WindowsOpenSSH"
  type_handler_version       = "3.0"
  auto_upgrade_minor_version = true
  depends_on = [
    azurerm_windows_virtual_machine.vm_addc
  ]
  lifecycle {
    ignore_changes = [tags]
  }
}

# extension to install DNS and AD Forest
resource "azurerm_virtual_machine_extension" "vm_addc_gpmc" {
  name                       = "InstallGPMC"
  virtual_machine_id         = azurerm_windows_virtual_machine.vm_addc.id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.10"
  auto_upgrade_minor_version = true
  settings                   = <<SETTINGS
    {
      "commandToExecute": "powershell.exe -Command \"${join(";", local.powershell_gpmc)}\""
    }
  SETTINGS
  depends_on = [
    azurerm_windows_virtual_machine.vm_addc,
    azurerm_virtual_machine_extension.vm_addc_openssh
  ]
  lifecycle {
    ignore_changes = [tags, settings]
  }
}

# time delay after gpmc
resource "time_sleep" "vm_addc_gpmc_sleep" {
  create_duration = "120s"
  depends_on = [
    azurerm_virtual_machine_extension.vm_addc_gpmc,
  ]
}

# Azure AD technical users with remote-exec module to use PowerShell
resource "terraform_data" "vm_addc_ad_user" {
  triggers_replace = [
    azurerm_virtual_machine_extension.vm_addc_openssh.id,
    azurerm_virtual_machine_extension.vm_addc_gpmc.id,
    time_sleep.vm_addc_gpmc_sleep.id
  ]

  # SSH connection to run posh script
  provisioner "remote-exec" {
    connection {
      type            = "ssh"
      user            = "${var.domain_netbios_name}\\${var.domain_admin_user}"
      password        = var.domain_admin_pswd
      host            = azurerm_public_ip.vm_addc_pip.ip_address
      target_platform = "windows"
      timeout         = "1m"
    }
    inline = [
      "powershell.exe -Command \"${join(";", local.powershell_add_users)}\""
    ]
  }
  depends_on = [
    time_sleep.vm_addc_gpmc_sleep,
  ]
}

# vm-addc OUTPUTS 
output "vm_addc_public_name" {
  value = azurerm_public_ip.vm_addc_pip.domain_name_label
}

output "vm_addc_public_ip" {
  value = azurerm_public_ip.vm_addc_pip.ip_address
}

# vm-addc LOCALS 
locals {
  # Generate locals for domain join parameters
  split_domain    = split(".", var.domain_name)
  dn_path         = join(",", [for dc in local.split_domain : "DC=${dc}"])
  servers_ou_path = "OU=Servers,${join(",", [for dc in local.split_domain : "DC=${dc}"])}"

  # Generate commands to install DNS and AD Forest
  powershell_gpmc = [
    "Set-NetFirewallProfile -Enabled False",
    "Install-WindowsFeature AD-Domain-Services -IncludeAllSubFeature -IncludeManagementTools",
    "Install-WindowsFeature DNS -IncludeAllSubFeature -IncludeManagementTools",
    "Import-Module ADDSDeployment, DnsServer",
    "Install-ADDSForest -DomainName ${var.domain_name} -DomainNetbiosName ${var.domain_netbios_name} -NoRebootOnCompletion:$false -Force:$true -SafeModeAdministratorPassword (ConvertTo-SecureString ${var.domain_admin_pswd} -AsPlainText -Force)"
  ]
  
  # Generate commands to create new Organization Unit and technical users for SQL installation
  powershell_add_users = [
    "New-Item -Path C:\\BUILD\\ -ItemType Directory -Force",
    "Start-Transcript -Path C:\\BUILD\\transcript-gpmc.txt",
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
