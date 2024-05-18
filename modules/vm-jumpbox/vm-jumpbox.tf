# v-network.tf
module "v_network" {
  source      = "../v-network"
  lab_name    = var.lab_name
  rg_location = var.rg_location
  rg_name     = var.rg_name
  tags        = var.tags
}

#################### vm-jumpbox ####################
# vm-jumpWin Publip IP with internet DNS hostname
resource "azurerm_public_ip" "vm_jumpwin_pip" {
  name                = "vm-jumpwin-pip"
  location            = var.rg_location
  resource_group_name = var.rg_name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = var.vm_jumpwin_hostname
  tags                = var.tags
  lifecycle {
    ignore_changes = [tags]
  }
}

# vm-jumpbox primary NIC 
resource "azurerm_network_interface" "vm_jumpwin_nic" {
  name                          = "vm-jumpwin-nic"
  location                      = var.rg_location
  resource_group_name           = var.rg_name
  enable_accelerated_networking = true
  tags                          = var.tags
  ip_configuration {
    name                          = "vm-jumpwin-ip"
    subnet_id                     = var.vm_snet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost("10.0.0.0/27", 7) //"10.0.0.7"
    primary                       = true
    public_ip_address_id          = azurerm_public_ip.vm_jumpwin_pip.id
  }
  lifecycle {
    ignore_changes = [tags]
  }
}

# vm-jumpWin Windows Jumpbox
resource "azurerm_windows_virtual_machine" "vm_jumpwin" {
  name                = "vm-jumpwin"
  location            = var.rg_location
  resource_group_name = var.rg_name
  size                = var.vm_size
  computer_name       = var.vm_jumpwin_hostname
  admin_username      = var.vm_localadmin_user
  admin_password      = var.vm_localadmin_pswd
  license_type        = "Windows_Client"
  tags                = var.tags
  os_disk {
    name                 = "vm-jumpwin-dsk0os"
    caching              = "ReadWrite"
    disk_size_gb         = "127"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-11"
    sku       = "win11-23h2-pro"
    version   = "latest"
  }
  custom_data = base64encode(<<EOF
    <powershell>
    Enable-PSRemoting -SkipNetworkProfileCheck -Verbose
    Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Private
    Enable-PSRemoting -Verbose
    Set-NetFirewallRule -Name WINRM-HTTP-In-TCP -RemoteAddress Any -Enabled True
    Start-Process -FilePath winrm -ArgumentList "quickconfig", "-q", "-Force" -nonewwindow -Verbose
    </powershell>
  EOF
  )
  network_interface_ids = [
    azurerm_network_interface.vm_jumpwin_nic.id,
  ]
  lifecycle {
    ignore_changes = [tags, custom_data]
  }
}

# vm-jumpWin associate NIC with NSG
resource "azurerm_network_interface_security_group_association" "vm_jumpwin_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.vm_jumpwin_nic.id
  network_security_group_id = azurerm_network_security_group.nsg_jumpbox.id
}

# Create extension to Open SSH on vm_jumpwin
resource "azurerm_virtual_machine_extension" "vm_jumpwin_openssh" {
  name                       = "InstallOpenSSH"
  virtual_machine_id         = azurerm_windows_virtual_machine.vm_jumpwin.id
  publisher                  = "Microsoft.Azure.OpenSSH"
  type                       = "WindowsOpenSSH"
  type_handler_version       = "3.0"
  auto_upgrade_minor_version = true
  lifecycle {
    ignore_changes = [tags]
  }
  depends_on = [
    azurerm_windows_virtual_machine.vm_jumpwin
  ]
}

# vm-jumpWin AUTOSHUTDOWN
resource "azurerm_dev_test_global_vm_shutdown_schedule" "vm_jumpwin_shutdown" {
  virtual_machine_id    = azurerm_windows_virtual_machine.vm_jumpwin.id
  location              = var.rg_location
  enabled               = true
  daily_recurrence_time = var.vm_shutdown_hhmm
  timezone              = var.vm_shutdown_tz
  notification_settings {
    enabled = false
  }
}

/* UNDER DEVELOPMENT
resource "null_resource" "jumpwin_copy_file" {
  connection {
    type     = "ssh"
    host     = azurerm_public_ip.vm_jumpwin_pip.ip_address
    user     = var.vm_localadmin_user
    password = var.vm_localadmin_pswd
    agent    = false
    timeout  = "2m"
  }
  provisioner "file" {
    source      = "../content/windows/get-mystuff.ps1"
    destination = "c:\\users\\public\\documents\\get-mystuff.bash"
  }
  depends_on = [
    azurerm_virtual_machine_extension.vm_jumpwin_openssh,
    azurerm_network_interface_security_group_association.vm_jumpwin_nsg_assoc,
  ]
}*/

########## vm-jumpLin 
# vm-jumpLin Publip IP with internet DNS hostname
resource "azurerm_public_ip" "vm_jumplin_pip" {
  name                = "vm-jumplin-pip"
  location            = var.rg_location
  resource_group_name = var.rg_name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = var.vm_jumplin_hostname
  tags                = var.tags
  lifecycle {
    ignore_changes = [tags]
  }
}

# Primary vm-jumpLin NIC for VM Internal Communication
resource "azurerm_network_interface" "vm_jumplin_nic" {
  name                          = "vm-jumplin-nic"
  location                      = var.rg_location
  resource_group_name           = var.rg_name
  enable_accelerated_networking = true
  tags                          = var.tags
  ip_configuration {
    name                          = "vm-jumplin-ip"
    subnet_id                     = var.vm_snet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost("10.0.0.0/27", 8) //"10.0.0.8"
    primary                       = true
    public_ip_address_id          = azurerm_public_ip.vm_jumplin_pip.id
  }
  lifecycle {
    ignore_changes = [tags]
  }
}

# Create vm-jumpLin Jumpbox
resource "azurerm_linux_virtual_machine" "vm_jumplin" {
  name                            = "vm-jumplin"
  location                        = var.rg_location
  resource_group_name             = var.rg_name
  size                            = var.vm_size
  computer_name                   = var.vm_jumplin_hostname
  admin_username                  = var.vm_localadmin_user
  admin_password                  = var.vm_localadmin_pswd
  disable_password_authentication = false
  tags                            = var.tags
  os_disk {
    name                 = "vm-jumplin-dsk0os"
    caching              = "ReadWrite"
    disk_size_gb         = "127"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  network_interface_ids = [
    azurerm_network_interface.vm_jumplin_nic.id,
  ]
  lifecycle {
    ignore_changes = [tags]
  }
}

# Associate vm-jumplin NIC with internal lab NSG
resource "azurerm_network_interface_security_group_association" "vm_jumplin_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.vm_jumplin_nic.id
  network_security_group_id = azurerm_network_security_group.nsg_jumpbox.id
}

# vm-jumpLin AUTOSHUTDOWN
resource "azurerm_dev_test_global_vm_shutdown_schedule" "vm_jumplin_shutdown" {
  virtual_machine_id    = azurerm_linux_virtual_machine.vm_jumplin.id
  location              = var.rg_location
  enabled               = true
  daily_recurrence_time = var.vm_shutdown_hhmm
  timezone              = var.vm_shutdown_tz
  notification_settings {
    enabled = false
  }
}

/* UNDER DEVELOPMENT
resource "null_resource" "jumplin_copy_file" {
  connection {
    type     = "ssh"
    host     = azurerm_public_ip.vm_jumplin_pip.ip_address
    user     = var.vm_localadmin_username
    password = var.vm_localadmin_password
    agent    = false
    timeout  = "2m"
  }
  provisioner "file" {
    source      = "../content/linux/get-mystuff.bash"
    destination = "/home/get-mystuff.bash"
  }
  depends_on = [
    azurerm_network_interface_security_group_association.vm_jumplin_nsg_assoc,
  ]
}*/

# Create NSG Lab
resource "azurerm_network_security_group" "nsg_jumpbox" {
  name                = "vnet-nsg-jumpbox"
  location            = var.rg_location
  resource_group_name = var.rg_name
  tags                = var.tags
  # NSG-Rule to allow SSH
  security_rule {
    name                       = "vnet-nsg-rule-SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  # NSG-Rule to allow RDP
  security_rule {
    name                       = "vnet-nsg-rule-RDP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  /*# NSG-Rule to allow WinRM
  security_rule {
    name                       = "vnet-nsg-rule-WinRM"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5985-5986"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }*/
  # NSG-Rule to allow ping
  security_rule {
    name                       = "vnet-nsg-rule-ping"
    priority                   = 900
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Icmp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  # NSG-Rule to allow ALL
  security_rule {
    name                       = "vnet-nsg-rule-local-all"
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
