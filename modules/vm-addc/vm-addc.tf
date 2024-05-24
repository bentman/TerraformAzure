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

# vm-addc Primary NIC 
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

# Create NSG for servers
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

# vm-addc associate NIC with NSG
resource "azurerm_network_interface_security_group_association" "vm_addc_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.vm_addc_nic.id
  network_security_group_id = azurerm_network_security_group.nsg_server.id
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

resource "azurerm_virtual_machine_extension" "vm_addc_openssh" {
  name                       = "InstallOpenSSH"
  virtual_machine_id         = azurerm_windows_virtual_machine.vm_addc.id
  publisher                  = "Microsoft.Azure.OpenSSH"
  type                       = "WindowsOpenSSH"
  type_handler_version       = "3.0"
  auto_upgrade_minor_version = true
  depends_on                 = [azurerm_windows_virtual_machine.vm_addc]
  lifecycle {
    ignore_changes = [tags, protected_settings]
  }
}

resource "azurerm_virtual_machine_extension" "vm_addc_dcpromo" {
  name                       = "InstallAddsDns"
  virtual_machine_id         = azurerm_windows_virtual_machine.vm_addc.id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.10"
  auto_upgrade_minor_version = true
  settings = jsonencode({
    "commandToExecute" : "powershell.exe -command ${local.powershell_dcpromo}"
  })
  depends_on = [azurerm_virtual_machine_extension.vm_addc_openssh]
  lifecycle {
    ignore_changes = [tags, settings, protected_settings]
  }
}

resource "time_sleep" "vm_addc_dcpromo_wait" {
  create_duration = "120s"
  depends_on      = [azurerm_virtual_machine_extension.vm_addc_dcpromo]
}

resource "azurerm_virtual_machine_extension" "vm_addc_dcpromo_restart" {
  name                       = "RestartVM"
  virtual_machine_id         = azurerm_windows_virtual_machine.vm_addc.id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.10"
  auto_upgrade_minor_version = true
  settings = jsonencode({
    "commandToExecute" : "powershell.exe -command ${local.powershell_dcpromo_restart}"
  })
  depends_on = [time_sleep.vm_addc_dcpromo_wait]
  lifecycle {
    ignore_changes = [tags, settings, protected_settings]
  }
}

resource "time_sleep" "vm_addc_dcpromo_restart_wait" {
  create_duration = "120s"
  depends_on      = [azurerm_virtual_machine_extension.vm_addc_dcpromo_restart]
}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "vm_addc_shutdown" {
  virtual_machine_id    = azurerm_windows_virtual_machine.vm_addc.id
  location              = var.rg_location
  enabled               = true
  daily_recurrence_time = var.vm_addc_shutdown_hhmm
  timezone              = var.vm_addc_shutdown_tz
  notification_settings {
    enabled = false
  }
}

/*# NOTE: Server 2019 EOL January 2024 ;-)
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
    sku       = "2019-Datacenter"
    version   = "latest"
  }
  network_interface_ids = [
    azurerm_network_interface.vm_addc_nic.id,
  ]
  lifecycle {
    ignore_changes = [tags]
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
    "commandToExecute" : "powershell.exe -command ${local.powershell_addsdns}"
  })
  depends_on = [azurerm_virtual_machine_extension.vm_addc_openssh]
  lifecycle {
    ignore_changes = [tags, settings]
  }
}

resource "time_sleep" "wait_addc_adddns_reboot" {
  create_duration = "120s"
  depends_on      = [azurerm_virtual_machine_extension.vm_addc_addsdns]
}*/
