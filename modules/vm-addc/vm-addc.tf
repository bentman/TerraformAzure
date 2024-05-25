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

# vm-addc associate NIC with NSG
resource "azurerm_network_interface_security_group_association" "vm_addc_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.vm_addc_nic.id
  network_security_group_id = azurerm_network_security_group.nsg_server.id
}

# create vm-addc
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
  network_interface_ids = [azurerm_network_interface.vm_addc_nic.id]
  lifecycle {
    ignore_changes = [tags]
  }
}

# enable OpenSSH for remote administration
resource "azurerm_virtual_machine_extension" "vm_addc_openssh" {
  name                       = "InstallOpenSSH"
  virtual_machine_id         = azurerm_windows_virtual_machine.vm_addc.id
  publisher                  = "Microsoft.Azure.OpenSSH"
  type                       = "WindowsOpenSSH"
  type_handler_version       = "3.0"
  auto_upgrade_minor_version = true
  lifecycle {
    ignore_changes = [tags]
  }
}

# setup vm-addc as first domain controller in active directory forest
resource "azurerm_virtual_machine_extension" "vm_addc_dcpromo" {
  name                       = "InstallAddsDns"
  virtual_machine_id         = azurerm_windows_virtual_machine.vm_addc.id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.10"
  auto_upgrade_minor_version = true
  settings = jsonencode({
    "commandToExecute" = "powershell.exe -EncodedCommand ${base64encode(data.template_file.dc_promo.rendered)}"
  })
  depends_on = [azurerm_virtual_machine_extension.vm_addc_openssh]
  lifecycle {
    ignore_changes = [tags]
  }
}

# enable dev\test shut down schedule (to save $)
resource "azurerm_dev_test_global_vm_shutdown_schedule" "vm_addc_shutdown" {
  virtual_machine_id    = azurerm_windows_virtual_machine.vm_addc.id
  location              = var.rg_location
  enabled               = true
  daily_recurrence_time = var.vm_addc_shutdown_hhmm
  timezone              = var.vm_addc_shutdown_tz
  depends_on            = [azurerm_windows_virtual_machine.vm_addc]
  notification_settings {
    enabled = false
  }
}

########## Create NSG for vm-addc (& other servers)
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
