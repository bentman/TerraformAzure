########## vm-addc (domain controller)
# vm-addc Public IP with internet DNS hostname
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
    subnet_id                     = var.snet_0128_server_id
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

# Create vm-addc
resource "azurerm_windows_virtual_machine" "vm_addc" {
  name                = "vm-addc"
  location            = var.rg_location
  resource_group_name = var.rg_name
  size                = var.vm_addc_size
  computer_name       = var.vm_addc_hostname
  admin_username      = var.vm_addc_localadmin_user
  admin_password      = var.vm_addc_localadmin_pswd
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

# Enable OpenSSH for remote administration
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

# Set VM timezone
resource "azurerm_virtual_machine_run_command" "vm_timezone_addc" {
  name               = "SetTimeZone"
  location           = var.rg_location
  virtual_machine_id = azurerm_windows_virtual_machine.vm_addc.id
  source {
    script = "Set-TimeZone -Name '${var.vm_shutdown_tz}' -Confirm:$false"
  }
  depends_on = [azurerm_virtual_machine_extension.vm_addc_openssh]
}

# Copy DCPromo script to VM
resource "null_resource" "vm_addc_dcpromo_copy" {
  provisioner "file" {
    source      = "${path.module}/${local.dcPromoScript}"
    destination = "C:\\${local.dcPromoScript}"
    connection {
      type            = "ssh"
      user            = var.vm_addc_localadmin_user
      password        = var.vm_addc_localadmin_pswd
      host            = azurerm_public_ip.vm_addc_pip.ip_address
      target_platform = "windows"
      timeout         = "5m"
    }
  }
  depends_on = [azurerm_virtual_machine_extension.vm_addc_openssh, ]
}

# Execute DCPromo script on VM
resource "null_resource" "vm_addc_dcpromo_exec" {
  provisioner "remote-exec" {
    inline = [
      "powershell.exe -ExecutionPolicy Unrestricted -File C:\\${local.dcPromoScript} -domain_name ${var.domain_name} -domain_netbios_name ${var.domain_netbios_name} -safemode_admin_pswd ${var.safemode_admin_pswd}"
    ]
    connection {
      type            = "ssh"
      user            = var.vm_addc_localadmin_user
      password        = var.vm_addc_localadmin_pswd
      host            = azurerm_public_ip.vm_addc_pip.ip_address
      target_platform = "windows"
      timeout         = "30m"
    }
  }
  depends_on = [
    null_resource.vm_addc_dcpromo_copy,
  ]
}

# Wait for DCPromo to complete
resource "time_sleep" "vm_addc_dcpromo_wait" {
  create_duration = "5m"
  depends_on      = [null_resource.vm_addc_dcpromo_exec, ]
}

# Restart VM after DCPromo
resource "azurerm_virtual_machine_run_command" "vm_addc_restart" {
  name               = "RestartCommand"
  location           = var.rg_location
  virtual_machine_id = azurerm_windows_virtual_machine.vm_addc.id
  source {
    script = "Restart-Computer -Force"
  }
  depends_on = [time_sleep.vm_addc_dcpromo_wait, ]
}

# Wait for vm-addc restart
resource "time_sleep" "vm_addc_restart_wait" {
  create_duration = "10m"
  depends_on = [
    azurerm_virtual_machine_run_command.vm_addc_restart
  ]
}

# SSH connection to create new OU and technical users for SQL installation
resource "terraform_data" "vm_addc_add_users" {
  triggers_replace = [
    azurerm_virtual_machine_extension.vm_addc_openssh,
    time_sleep.vm_addc_dcpromo_wait
  ]
  provisioner "remote-exec" {
    connection {
      type            = "ssh"
      user            = "${var.domain_netbios_name}\\${var.vm_addc_localadmin_user}"
      password        = var.vm_addc_localadmin_user
      host            = azurerm_public_ip.vm_addc_pip.ip_address
      target_platform = "windows"
      timeout         = "10m"
    }
    inline = [
      "powershell.exe -Command \"${join(";", local.powershell_add_users)}\""
    ]
  }
  depends_on = [time_sleep.vm_addc_restart_wait, ]
}

# Copy serverstuff script to VM
resource "null_resource" "vm_server_stuff_copy" {
  provisioner "file" {
    source      = "${path.module}/${local.server_stuff}"
    destination = "C:\\Users\\Public\\Documents\\${local.server_stuff}"
    connection {
      type            = "ssh"
      user            = "${var.domain_netbios_name}\\${var.vm_addc_localadmin_user}"
      password        = var.vm_addc_localadmin_user
      host            = azurerm_public_ip.vm_addc_pip.ip_address
      target_platform = "windows"
      timeout         = "5m"
    }
  }
  depends_on = [terraform_data.vm_addc_add_users, ]
}

# Enable dev\test shutdown schedule (to save $)
resource "azurerm_dev_test_global_vm_shutdown_schedule" "vm_addc_shutdown" {
  virtual_machine_id    = azurerm_windows_virtual_machine.vm_addc.id
  location              = var.rg_location
  enabled               = true
  daily_recurrence_time = var.vm_addc_shutdown_hhmm
  timezone              = var.vm_shutdown_tz
  depends_on            = [azurerm_windows_virtual_machine.vm_addc, ]
  notification_settings {
    enabled = false
  }
}
