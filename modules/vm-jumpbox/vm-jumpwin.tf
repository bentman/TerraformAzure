########## vm-jumpWin 
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
    "Set-TimeZone -Name '${var.vm_shutdown_tz}' -Confirm:$false"    
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
    source      = "../../content/vm-windows/get-mystuff.ps1"
    destination = "c:\\users\\public\\documents\\get-mystuff.ps1"
  }
  depends_on = [
    azurerm_virtual_machine_extension.vm_jumpwin_openssh,
    azurerm_network_interface_security_group_association.vm_jumpwin_nsg_assoc,
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
