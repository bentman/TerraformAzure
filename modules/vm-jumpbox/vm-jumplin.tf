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
  name                           = "vm-jumplin-nic"
  location                       = var.rg_location
  resource_group_name            = var.rg_name
  accelerated_networking_enabled = true
  tags                           = var.tags
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
    sku       = var.vm_jumplin_sku
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
  depends_on = [
    azurerm_network_interface_security_group_association.vm_jumplin_nsg_assoc,
  ]
}

resource "null_resource" "jumplin_copy_file" {
  provisioner "file" {
    source      = "${path.module}/get-mystuff.bash"
    destination = "~/get-mystuff.bash"
    connection {
      type     = "ssh"
      user     = var.vm_localadmin_user
      password = var.vm_localadmin_pswd
      host     = azurerm_public_ip.vm_jumplin_pip.ip_address
      agent    = false
      timeout  = "2m"
    }
  }
  depends_on = [
    azurerm_linux_virtual_machine.vm_jumplin,
  ]
}

### Work-in-Progress
/*# Set VM timezone
resource "azurerm_virtual_machine_run_command" "vm_timezone_addc" {
  name               = "SetTimeZone"
  location           = var.rg_location
  virtual_machine_id = azurerm_windows_virtual_machine.vm_addc.id
  source {
    script = "sudo timedatectl set-timezone '${var.vm_shutdown_tz}'"
  }
  depends_on = [
    azurerm_dev_test_global_vm_shutdown_schedule.vm_jumplin_shutdown,
  ]
}*/
