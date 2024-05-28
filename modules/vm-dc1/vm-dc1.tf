########## vm-dc1 (domain controller)
# vm-dc1 Public IP with internet DNS hostname
resource "azurerm_public_ip" "vm_dc1_pip" {
  name                = "${var.vm_dc1_hostname}-pip"
  location            = var.rg_location
  resource_group_name = var.rg_name
  domain_name_label   = var.vm_dc1_hostname
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
  lifecycle {
    ignore_changes = [tags]
  }
}

# vm-dc1 Primary NIC 
resource "azurerm_network_interface" "vm_dc1_nic" {
  name                          = "${var.vm_dc1_hostname}-nic"
  location                      = var.rg_location
  resource_group_name           = var.rg_name
  enable_accelerated_networking = true
  tags                          = var.tags
  ip_configuration {
    name                          = "${var.vm_dc1_hostname}-ip"
    subnet_id                     = var.vm_server_snet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost("10.0.0.128/25", 42) // "10.0.0.170"
    primary                       = true
    public_ip_address_id          = azurerm_public_ip.vm_dc1_pip.id
  }
  lifecycle {
    ignore_changes = [tags]
  }
}

# vm-dc1 associate NIC with NSG
resource "azurerm_network_interface_security_group_association" "vm_dc1_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.vm_dc1_nic.id
  network_security_group_id = azurerm_network_security_group.nsg_dc1.id
}

# Create vm-dc1
resource "azurerm_windows_virtual_machine" "vm_addc" {
  name                = "${var.vm_dc1_hostname}"
  location            = var.rg_location
  resource_group_name = var.rg_name
  size                = var.vm_dc1_size
  computer_name       = var.vm_dc1_hostname
  admin_username      = var.vm_localadmin_user
  admin_password      = var.vm_localadmin_pswd
  license_type        = "Windows_Server"
  tags                = var.tags
  os_disk {
    name                 = "${var.vm_dc1_hostname}-dsk0os"
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
  network_interface_ids = [azurerm_network_interface.vm_dc1_nic.id]
  lifecycle {
    ignore_changes = [tags]
  }
}

# Enable dev\test shutdown schedule (to save $)
resource "azurerm_dev_test_global_vm_shutdown_schedule" "vm_dc1_shutdown" {
  virtual_machine_id    = azurerm_windows_virtual_machine.vm_addc.id
  location              = var.rg_location
  enabled               = true
  daily_recurrence_time = var.vm_dc1_shutdown_hhmm
  timezone              = var.vm_shutdown_tz
  depends_on            = [azurerm_windows_virtual_machine.vm_addc]
  notification_settings {
    enabled = false
  }
}

# Enable OpenSSH for remote administration
resource "azurerm_virtual_machine_extension" "vm_dc1_openssh" {
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

# Set VM timezone
resource "azurerm_virtual_machine_run_command" "vm_dc1_timezone" {
  name               = "SetTimeZone"
  location           = var.rg_location
  virtual_machine_id = azurerm_windows_virtual_machine.vm_addc.id
  source {
    script = "Set-TimeZone -Name '${var.vm_shutdown_tz}' -Confirm:$false"
  }
  depends_on = [azurerm_virtual_machine_extension.vm_dc1_openssh]
}

# Copy DCPromo script to VM
resource "null_resource" "vm_dc1_dcpromo_copy" {
  provisioner "file" {
    source      = "${path.module}/${local.dcPromoScript}"
    destination = "C:\\${local.dcPromoScript}"
    connection {
      type            = "ssh"
      user            = var.vm_localadmin_user
      password        = var.vm_localadmin_pswd
      host            = azurerm_public_ip.vm_dc1_pip.ip_address
      target_platform = "windows"
      timeout         = "120s"
    }
  }

  depends_on = [azurerm_virtual_machine_run_command.vm_dc1_timezone]
}

# Execute DCPromo script on VM
resource "null_resource" "vm_dc1_dcpromo_exec" {
  provisioner "remote-exec" {
    inline = [
      "powershell.exe -ExecutionPolicy Unrestricted -File C:\\${local.dcPromoScript} -domain_name ${var.dc1_domain_name} -domain_netbios_name ${var.dc1_domain_netbios_name} -safemode_admin_pswd ${var.dc1_safemode_admin_pswd}"
    ]
    connection {
      type            = "ssh"
      user            = var.vm_localadmin_user
      password        = var.vm_localadmin_pswd
      host            = azurerm_public_ip.vm_dc1_pip.ip_address
      target_platform = "windows"
      timeout         = "20m"
    }
  }
  depends_on = [null_resource.vm_dc1_dcpromo_copy]
}

# Wait for DCPromo to complete
resource "time_sleep" "vm_dc1_dcpromo_wait" {
  create_duration = "3m"
  depends_on      = [null_resource.vm_dc1_dcpromo_exec]
}

# Restart VM after DCPromo
resource "azurerm_virtual_machine_run_command" "vm_dc1_restart" {
  name               = "RestartCommand"
  location           = var.rg_location
  virtual_machine_id = azurerm_windows_virtual_machine.vm_addc.id
  source {
    script = "Restart-Computer -Force"
  }
  depends_on = [time_sleep.vm_dc1_dcpromo_wait]
}

########## Create NSG for vm-dc1 (& other servers)
resource "azurerm_network_security_group" "nsg_dc1" {
  name                = "vnet-nsg-dc1"
  location            = var.rg_location
  resource_group_name = var.rg_name
  tags                = var.tags
  # NSG rule to allow SSH
  security_rule {
    name                       = "vnet-nsg-dc1-SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  # NSG rule to allow RDP
  security_rule {
    name                       = "vnet-nsg-dc1-RDP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  # NSG rule to allow ping
  security_rule {
    name                       = "vnet-nsg-dc1-ping"
    priority                   = 900
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Icmp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  # NSG rule to allow all internal traffic
  security_rule {
    name                       = "vnet-nsg-dc1-local-all"
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
