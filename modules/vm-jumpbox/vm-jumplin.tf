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
  custom_data = base64encode(<<EOF
    #!/bin/bash
    sudo timedatectl set-timezone '${var.vm_shutdown_tz}'
  EOF
  )
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

resource "null_resource" "jumplin_copy_file" {
  connection {
    type     = "ssh"
    host     = azurerm_public_ip.vm_jumplin_pip.ip_address
    user     = var.vm_localadmin_user
    password = var.vm_localadmin_pswd
    agent    = false
    timeout  = "2m"
  }
  provisioner "file" {
    source      = "../../content/vm-linux/get-mystuff.bash"
    destination = "/home/get-mystuff.bash"
  }
  depends_on = [
    azurerm_network_interface_security_group_association.vm_jumplin_nsg_assoc,
  ]
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
