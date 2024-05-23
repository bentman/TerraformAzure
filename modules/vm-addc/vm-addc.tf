########## vm-addc (domain controller)
# vm-addc Publip IP with internet DNS hostname
resource "azurerm_public_ip" "vm_addc_pip" {
  name                = "vm-addc-pip"
  location            = var.rg_location
  resource_group_name = var.rg_name
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
  location                      = var.rg_location
  resource_group_name           = var.rg_name
  enable_accelerated_networking = true
  tags                          = var.tags
  ip_configuration {
    name                          = "vm-addc-ip"
    subnet_id                     = var.vm_server_snet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost("10.0.0.128/25", 22) // "10.0.0.150"
    primary                       = true
    public_ip_address_id          = azurerm_public_ip.vm_addc_pip.id
  }
  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_windows_virtual_machine" "vm_addc" {
  name                = "vm-addc"
  location            = var.rg_location
  resource_group_name = var.rg_name
  size                = var.vm_addc_size
  computer_name       = var.vm_addc_hostname
  admin_username      = var.vm_localadmin_user
  admin_password      = var.vm_localadmin_pswd
  license_type        = "Windows_Server"
  tags                = var.tags
  os_disk {
    name                 = "vm-addc-dsk0os"
    caching              = "ReadWrite"
    disk_size_gb         = 127
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
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
  network_security_group_id = azurerm_network_security_group.nsg_server.id
}

# vm-addc AUTOSHUTDOWN
resource "azurerm_dev_test_global_vm_shutdown_schedule" "vm_addc_shutown" {
  virtual_machine_id    = azurerm_windows_virtual_machine.vm_addc.id
  location              = var.rg_location
  enabled               = true
  daily_recurrence_time = var.vm_addc_shutdown_hhmm
  timezone              = var.vm_addc_shutdown_tz
  notification_settings {
    enabled = false
  }
}

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

resource "null_resource" "wait_addc_adddns_reboot" {
  provisioner "local-exec" {
    command = <<EOT
      for ((i = 0; i < 30; i++)); do
        if ping -n 1 -w 1 ${azurerm_public_ip.vm_addc_pip.ip_address} > nul; then
          exit 0
        fi
        sleep 10
      done
      exit 1
    EOT
  }
  depends_on = [azurerm_virtual_machine_extension.vm_addc_addsdns]
}

resource "null_resource" "vm_addc_dcpromo" {
  connection {
    type            = "ssh"
    user            = var.vm_localadmin_user
    password        = var.vm_localadmin_pswd
    host            = azurerm_network_interface.vm_addc_nic.private_ip_address
    target_platform = "windows"
    timeout         = "15m"
  }
  provisioner "remote-exec" {
    inline = [
      "Start-Transcript -Path 'c:\\BUILD\\02-adds_forest.log'",
      "Set-PSRepository -Name PSGallery -InstallationPolicy Trusted",
      "Import-Module -Name ADDSDeployment -Verbose",
      "Import-Module -Name DnsServer -Verbose",
      "Install-ADDSForest -DomainName '${var.domain_name}' -DomainNetBiosName '${var.domain_netbios_name}' -InstallDns -SafeModeAdministratorPassword (ConvertTo-SecureString '${var.safemode_admin_pswd}' -AsPlainText -Force) -NoRebootOnCompletion:$true -LogPath 'C:\\BUILD\\adpromo.log' -Confirm:$false -Force -Verbose",
      "Set-NetFirewallProfile -Profile Domain -Enabled:false",
      "Stop-Transcript",
      "exit 0",
      "Restart-Computer -Delay 15s -Force"
    ]
  }
  depends_on = [ null_resource.wait_addc_adddns_reboot ]
}

resource "null_resource" "wait_addc_dcpromo_reboot" {
  provisioner "local-exec" {
    command = <<EOT
      for ((i = 0; i < 30; i++)); do
        if ping -n 1 -w 1 ${azurerm_public_ip.vm_addc_pip.ip_address} > nul; then
          exit 0
        fi
        sleep 10
      done
      exit 1
    EOT
  }
  depends_on = [ null_resource.vm_addc_dcpromo ]
}

# Create NSG server
resource "azurerm_network_security_group" "nsg_server" {
  name                = "vnet-nsg-server"
  location            = var.rg_location
  resource_group_name = var.rg_name
  tags                = var.tags
  # nsg-server to allow SSH
  security_rule {
    name                       = "vnet-nsg-server-SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  # nsg-server to allow RDP
  security_rule {
    name                       = "vnet-nsg-server-RDP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  /*# nsg-server to allow WinRM
  security_rule {
    name                       = "vnet-nsg-server-WinRM"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5985-5986"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }*/
  # nsg-server to allow ping
  security_rule {
    name                       = "vnet-nsg-server-ping"
    priority                   = 900
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Icmp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  # nsg-server to allow ALL
  security_rule {
    name                       = "vnet-nsg-server-local-all"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "10.0.0.0/23"
    destination_address_prefix = "*"
  }
  lifecycle {
    ignore_changes = [tags]
  }
}

/*# Azure AD technical users with remote-exec module to use PowerShell
resource "terraform_data" "vm_addc_ad_user" {
  triggers_replace = [
    azurerm_virtual_machine_extension.vm_addc_openssh.id,
    azurerm_virtual_machine_extension.vm_addc_gpmc.id,
    time_sleep.vm_addc_gpmc_sleep.id
  ]

}*/
